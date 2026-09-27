#!/usr/bin/env python3
"""Back up the user files and GSettings changed by the extras installer."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys

KEYS = ('gtk-theme', 'icon-theme', 'font-name', 'color-scheme')
SCHEMA = 'org.gnome.desktop.interface'

def exists(path):
    return os.path.lexists(path)

def copy(source, dest):
    if source.is_symlink():
        dest.symlink_to(os.readlink(source))
    elif source.is_dir():
        shutil.copytree(source, dest, symlinks=True)
    else:
        shutil.copy2(source, dest)

mode, folder, *arguments = sys.argv[1:]
root = Path(folder)
manifest = root / 'manifest.json'
if mode == 'backup':
    if manifest.exists():
        print(f'Keeping original extras backup: {root}')
        sys.exit(0)
    root.mkdir(parents=True, exist_ok=False)
    paths = []
    for index, value in enumerate(arguments):
        path = Path(value)
        present = exists(path)
        paths.append({'path': str(path), 'present': present})
        if present:
            copy(path, root / str(index))
    settings = {key: subprocess.check_output(['gsettings', 'get', SCHEMA, key], text=True).strip()
                for key in KEYS}
    manifest.write_text(json.dumps({'paths': paths, 'settings': settings}, indent=2))
elif mode in ('restore', 'preview'):
    if not manifest.exists():
        sys.exit('No extras backup found.')
    data = json.loads(manifest.read_text())
    for index, entry in enumerate(data['paths']):
        if entry['present'] and not exists(root / str(index)):
            sys.exit(f'Missing extras backup: {index}; no files changed.')
    if mode == 'preview':
        for entry in data['paths']:
            print('Would restore: ' + entry['path'])
        print('Would restore saved desktop theme settings.')
        sys.exit(0)
    # Keep the modified files rather than deleting them during rollback.
    import tempfile
    archive = Path(tempfile.mkdtemp(prefix='extras-replaced-', dir=root.parent))
    for index, entry in enumerate(data['paths']):
        path = Path(entry['path'])
        if exists(path):
            shutil.move(str(path), archive / str(index))
        if entry['present']:
            path.parent.mkdir(parents=True, exist_ok=True)
            copy(root / str(index), path)
    for key, value in data['settings'].items():
        subprocess.run(['gsettings', 'set', SCHEMA, key, value], check=True)
    root.rename(archive / 'original-backup')
    print(f'Extras restored. Replaced files preserved in {archive}')
else:
    sys.exit('Unknown state operation')
