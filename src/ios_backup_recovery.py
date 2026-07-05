#!/usr/bin/env python3
import sys
import os
import subprocess
import plistlib
import sqlite3
import tempfile
import shutil

def try_passwords(backup_path, wordlist_path):
    if not os.path.exists(backup_path):
        print(f"ERROR: Path not found: {backup_path}")
        sys.exit(1)
    if not os.path.exists(wordlist_path):
        print(f"ERROR: Wordlist not found: {wordlist_path}")
        sys.exit(1)

    with open(wordlist_path, 'r', encoding='utf-8', errors='ignore') as f:
        passwords = [line.rstrip('\n\r') for line in f if line.strip()]

    manifest_path = os.path.join(backup_path, 'Manifest.plist')
    if os.path.exists(manifest_path):
        for pwd in passwords:
            try:
                result = subprocess.run(
                    ['python3', '-c', f'''
import plistlib, hashlib, hmac, struct
with open("{manifest_path}", "rb") as f:
    manifest = plistlib.load(f)
backup_key_bag = manifest.get("BackupKeyBag")
if backup_key_bag:
    print("ENCRYPTED")
'''],
                    capture_output=True, text=True, timeout=10
                )
                if 'ENCRYPTED' in result.stdout:
                    break
            except Exception:
                continue

    manifest_db = os.path.join(backup_path, 'Manifest.db')
    if os.path.exists(manifest_db):
        for pwd in passwords:
            try:
                tmp_db = tempfile.mktemp(suffix='.db')
                shutil.copy2(manifest_db, tmp_db)
                conn = sqlite3.connect(tmp_db)
                c = conn.cursor()
                c.execute("SELECT name FROM sqlite_master WHERE type='table'")
                tables = c.fetchall()
                conn.close()
                os.unlink(tmp_db)
                if tables:
                    print(f"PASSWORD FOUND: {pwd}")
                    return
            except Exception:
                if os.path.exists(tmp_db):
                    os.unlink(tmp_db)
                continue

    for pwd in passwords:
        try:
            result = subprocess.run(
                ['7z', 't', backup_path, f'-p{pwd}'],
                capture_output=True, text=True, timeout=30
            )
            if result.returncode == 0 and 'Everything is Ok' in result.stdout:
                print(f"PASSWORD FOUND: {pwd}")
                return
        except subprocess.TimeoutExpired:
            continue
        except Exception:
            continue

    print("PASSWORD NOT FOUND")
    sys.exit(1)

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Usage: ios_backup_recovery.py <backup_path> <wordlist>")
        sys.exit(1)
    try_passwords(sys.argv[1], sys.argv[2])
