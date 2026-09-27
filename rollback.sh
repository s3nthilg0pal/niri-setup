#!/bin/bash
set -euo pipefail
if (( EUID == 0 )); then
  echo 'Run rollback as your desktop user, without sudo.' >&2
  exit 1
fi
once=false
dry_run=false
for argument in "$@"; do
  case "$argument" in
    --once) once=true ;;
    --dry-run) dry_run=true ;;
    -h|--help)
      echo 'Usage: ./rollback.sh [--once] [--dry-run]'
      echo 'Restore all recorded setup generations, or only the latest with --once.'
      echo 'Current files are archived; installed RPMs are left in place.'
      exit 0 ;;
    *) echo "Unknown option: $argument" >&2; exit 1 ;;
  esac
done
python3 - "${XDG_CONFIG_HOME:-$HOME/.config}" "$once" "$dry_run" <<'PY'
import json
import os
from pathlib import Path
import re
import sys
import tempfile

config = Path(sys.argv[1])
once = sys.argv[2] == 'true'
dry_run = sys.argv[3] == 'true'
names = ('niri-setup', 'niri')
target = config / 'niri-setup'

def exists(path):
    return os.path.lexists(path)

def fail(message):
    sys.exit('Rollback stopped: ' + message)

# Preflight the full chain before moving any user files.
plans = []
current = target
seen = set()
while current.is_dir() and not current.is_symlink():
    metadata = current / '.rollback.json'
    if not metadata.is_file():
        break
    try:
        data = json.loads(metadata.read_text())
        suffix = data['suffix']
        previous = data['existed']
        assert data['version'] == 1
        assert re.fullmatch(r'backup-\d{8}-\d{6}-\d+', suffix)
        assert set(previous) == set(names)
        assert all(type(value) is bool for value in previous.values())
        assert suffix not in seen
    except (ValueError, KeyError, TypeError, AssertionError):
        fail(f'invalid metadata in {metadata}')
    seen.add(suffix)
    for name in names:
        backup = config / f'{name}.{suffix}'
        if previous[name] and not exists(backup):
            fail(f'missing backup {backup}; no files were changed')
    plans.append((suffix, previous))
    if once or not previous['niri-setup']:
        break
    current = config / f'niri-setup.{suffix}'

if not plans:
    fail('no recorded setup to undo. Older installations without .rollback.json '
         'require manual restoration from their .backup-* directories.')

if dry_run:
    for suffix, previous in plans:
        for name in names:
            action = f'restore {name}.{suffix}' if previous[name] else f'restore absence of {name}'
            print(f'Would archive current {name}, then {action}.')
    print('No files or packages have been changed. RPMs and runtime state would be retained.')
    sys.exit(0)

archive = Path(tempfile.mkdtemp(prefix='niri-rollback-', dir=config))
for index, (suffix, previous) in enumerate(plans, 1):
    generation = archive / str(index)
    generation.mkdir()
    moved = []
    restored = []
    try:
        for name in names:
            path = config / name
            if exists(path):
                path.rename(generation / name)
                moved.append(name)
        for name in names:
            if previous[name]:
                (config / f'{name}.{suffix}').rename(config / name)
                restored.append(name)
    except OSError as error:
        # Recover this generation if a move fails partway through.
        for name in reversed(restored):
            (config / name).rename(config / f'{name}.{suffix}')
        for name in reversed(moved):
            (generation / name).rename(config / name)
        fail(f'{error}; recovery files are in {archive}')
    print(f'Restored configuration from before {suffix}.')
print(f'Preserved replaced files in {archive}')
print('Installed RPMs and runtime state (such as the idle timer) are unchanged.')
print('Log out and select your previous desktop session to finish.')
PY
