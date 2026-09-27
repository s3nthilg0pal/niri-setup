"""Isolated smoke tests; no package installs or changes to the desktop."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class FedoraTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.bin = self.root / 'bin'
        self.bin.mkdir()
        self.env = dict(os.environ, XDG_CONFIG_HOME=str(self.root / 'config'),
                        XDG_STATE_HOME=str(self.root / 'state'),
                        PATH=f'{self.bin}:' + os.environ['PATH'])

    def mock(self, name, body):
        path = self.bin / name
        path.write_text('#!/bin/bash\n' + body + '\n')
        path.chmod(0o755)

    def run_script(self, path, *args):
        return subprocess.run(['bash', str(ROOT / path), *args], env=self.env,
                              capture_output=True, text=True)

    def test_update_states(self):
        for code, output, expected in [
            (0, '', '0'),
            (100, 'Updates available\nfoo.x86_64 1.2 updates\nbar.noarch 2.0 fedora', '2'),
            (1, 'Repository error', '?'),
        ]:
            self.mock('dnf', f"printf '%s\\n' '{output}'\nexit {code}")
            result = self.run_script('waybar/modules/count-updates.sh')
            self.assertEqual(result.returncode, 0)
            self.assertEqual(json.loads(result.stdout)['text'], expected)

    def test_install_rerun_and_validation_failure(self):
        self.mock('niri', 'exit 0')
        config = Path(self.env['XDG_CONFIG_HOME'])
        original = config / 'niri'
        original.mkdir(parents=True)
        (original / 'keep').write_text('original')
        for _ in range(2):
            result = self.run_script('setup.sh', '--skip-install')
            self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(original.is_symlink())
        self.assertEqual(len(list(config.glob('niri.backup-*'))), 2)
        installed = config / 'niri-setup'
        binds = (installed / 'niri/binds.kdl').read_text()
        self.assertNotIn('$NIRICONF', binds)
        self.assertIn(str(installed), binds)
        self.assertIn('$NIRICONF', (ROOT / 'niri/binds.kdl').read_text())
        self.mock('niri', 'exit 1')
        self.assertNotEqual(self.run_script('setup.sh', '--skip-install').returncode, 0)
        self.assertEqual((installed / 'niri/binds.kdl').read_text(), binds)
        self.assertFalse(list(config.glob('.niri-setup.*')))

    def install(self):
        self.mock('niri', 'exit 0')
        result = self.run_script('setup.sh', '--skip-install')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_dry_run_does_not_write_or_install(self):
        self.mock('sudo', 'exit 99')
        self.mock('niri', 'exit 99')
        before = sorted(self.root.rglob('*'))
        result = self.run_script('dryrun.sh')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('sudo dnf install', result.stdout)
        self.assertEqual(sorted(self.root.rglob('*')), before)

    def test_rollback_restores_original_after_reruns(self):
        config = Path(self.env['XDG_CONFIG_HOME'])
        original = config / 'niri'
        original.mkdir(parents=True)
        (original / 'keep').write_text('original')
        self.install()
        self.install()
        before = sorted(config.rglob('*'))
        preview = self.run_script('rollback.sh', '--dry-run')
        self.assertEqual(preview.returncode, 0, preview.stderr)
        self.assertEqual(sorted(config.rglob('*')), before)
        result = self.run_script('rollback.sh')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(original.is_symlink())
        self.assertEqual((original / 'keep').read_text(), 'original')
        self.assertFalse((config / 'niri-setup').exists())
        self.assertEqual(len(list(config.glob('niri-rollback-*'))), 1)
        self.assertNotEqual(self.run_script('rollback.sh').returncode, 0)

    def test_rollback_first_install_and_once(self):
        config = Path(self.env['XDG_CONFIG_HOME'])
        self.install()
        self.install()
        self.assertEqual(self.run_script('rollback.sh', '--once').returncode, 0)
        self.assertTrue((config / 'niri').is_symlink())
        self.assertEqual(self.run_script('rollback.sh').returncode, 0)
        self.assertFalse(os.path.lexists(config / 'niri'))
        self.assertFalse((config / 'niri-setup').exists())

    def test_rollback_restores_broken_symlink(self):
        config = Path(self.env['XDG_CONFIG_HOME'])
        config.mkdir()
        (config / 'niri').symlink_to('missing-original')
        self.install()
        self.assertEqual(self.run_script('rollback.sh').returncode, 0)
        self.assertEqual(os.readlink(config / 'niri'), 'missing-original')

    def test_missing_backup_stops_rollback_before_changes(self):
        config = Path(self.env['XDG_CONFIG_HOME'])
        (config / 'niri').mkdir(parents=True)
        self.install()
        next(config.glob('niri.backup-*')).rmdir()
        before = sorted(config.rglob('*'))
        result = self.run_script('rollback.sh')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('missing backup', result.stderr)
        self.assertEqual(sorted(config.rglob('*')), before)

    def test_package_failure_does_not_write_config(self):
        self.mock('sudo', 'exit 1')
        self.assertNotEqual(self.run_script('setup.sh').returncode, 0)
        self.assertFalse(Path(self.env['XDG_CONFIG_HOME']).exists())


if __name__ == '__main__':
    unittest.main()
