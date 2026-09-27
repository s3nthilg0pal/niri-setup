"""Exercise extras preview, reversible state, and wallpaper mode persistence."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class ExtrasTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.bin = self.root / 'bin'
        self.bin.mkdir()
        self.env = dict(os.environ, PATH=f'{self.bin}:' + os.environ['PATH'],
                        XDG_CONFIG_HOME=str(self.root / 'config'),
                        XDG_DATA_HOME=str(self.root / 'data'),
                        XDG_STATE_HOME=str(self.root / 'state'))

    def mock(self, name, body):
        path = self.bin / name
        path.write_text('#!/bin/bash\n' + body + '\n')
        path.chmod(0o755)

    def test_preview_has_no_side_effects(self):
        before = sorted(self.root.rglob('*'))
        result = subprocess.run(['bash', ROOT / 'install-extras.sh', '--dry-run'],
                                env=self.env, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(before, sorted(self.root.rglob('*')))

    def test_snapshot_restore_files_symlinks_and_absence(self):
        self.mock('gsettings', "if [[ $1 == get ]]; then echo \"'original'\"; fi")
        file = self.root / 'settings'
        file.write_text('before')
        link = self.root / 'link'
        link.symlink_to('missing')
        absent = self.root / 'absent'
        backup = self.root / 'backup'
        command = ['python3', str(ROOT / 'extras/state.py')]
        subprocess.run(command + ['backup', str(backup), str(file), str(link), str(absent)],
                       env=self.env, check=True, capture_output=True)
        file.write_text('after')
        link.unlink()
        link.write_text('changed')
        absent.mkdir()
        (absent / 'new').write_text('keep this')
        # A second backup must not replace the original snapshot.
        subprocess.run(command + ['backup', str(backup), str(file)], env=self.env,
                       check=True, capture_output=True)
        subprocess.run(command + ['restore', str(backup)], env=self.env,
                       check=True, capture_output=True)
        self.assertEqual(file.read_text(), 'before')
        self.assertEqual(os.readlink(link), 'missing')
        self.assertFalse(absent.exists())
        self.assertEqual(next(self.root.glob('extras-replaced-*/2/new')).read_text(), 'keep this')

    def test_wallpaper_modes_and_invalid_mode_fallback(self):
        folder = self.root / 'wallpapers'
        folder.mkdir()
        source = (ROOT / 'scripts/start-wallpaper.sh').read_text().replace('$NIRICONF', str(self.root))
        script = self.root / 'start.sh'
        script.write_text(source)
        self.mock('swaybg', "printf '%s\\n' \"$@\"")
        for mode in ('stretch', 'fill', 'fit', 'center', 'tile', 'invalid; echo unsafe'):
            (folder / 'mode').write_text(mode + '\n')
            result = subprocess.run(['bash', str(script)], env=self.env,
                                    check=True, capture_output=True, text=True)
            arguments = result.stdout.splitlines()
            self.assertEqual(arguments[arguments.index('-m') + 1], mode if ';' not in mode else 'fill')


if __name__ == '__main__':
    unittest.main()
