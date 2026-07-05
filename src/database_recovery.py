#!/usr/bin/env python3
import sys
import os
import subprocess

def try_passwords(file_path, wordlist_path):
    if not os.path.exists(file_path):
        print(f"ERROR: File not found: {file_path}")
        sys.exit(1)
    if not os.path.exists(wordlist_path):
        print(f"ERROR: Wordlist not found: {wordlist_path}")
        sys.exit(1)

    with open(wordlist_path, 'r', encoding='utf-8', errors='ignore') as f:
        passwords = [line.rstrip('\n\r') for line in f if line.strip()]

    for pwd in passwords:
        try:
            result = subprocess.run(
                ['sqlcipher', file_path,
                 f"PRAGMA key = '{pwd}'; SELECT count(*) FROM sqlite_master;"],
                capture_output=True, text=True, timeout=15
            )
            if result.returncode == 0 and 'ok' in result.stdout.lower():
                print(f"PASSWORD FOUND: {pwd}")
                return
        except subprocess.TimeoutExpired:
            continue
        except FileNotFoundError:
            pass
        except Exception:
            continue

    for pwd in passwords:
        try:
            result = subprocess.run(
                ['mysql', '-u', 'root', '-p' + pwd, '-e', 'SELECT 1'],
                capture_output=True, timeout=15
            )
            if result.returncode == 0:
                print(f"PASSWORD FOUND: {pwd}")
                return
        except subprocess.TimeoutExpired:
            continue
        except FileNotFoundError:
            pass
        except Exception:
            continue

    for pwd in passwords:
        try:
            result = subprocess.run(
                ['psql', '-c', 'SELECT 1', 'postgresql://postgres:' + pwd + '@localhost/postgres'],
                capture_output=True, timeout=15
            )
            if result.returncode == 0:
                print(f"PASSWORD FOUND: {pwd}")
                return
        except subprocess.TimeoutExpired:
            continue
        except FileNotFoundError:
            pass
        except Exception:
            continue

    for pwd in passwords:
        try:
            result = subprocess.run(
                ['mongosh', '--eval', 'db.runCommand({ping:1})',
                 'mongodb://admin:' + pwd + '@localhost:27017'],
                capture_output=True, timeout=15
            )
            if result.returncode == 0:
                print(f"PASSWORD FOUND: {pwd}")
                return
        except subprocess.TimeoutExpired:
            continue
        except FileNotFoundError:
            pass
        except Exception:
            continue

    print("PASSWORD NOT FOUND")
    sys.exit(1)

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Usage: database_recovery.py <db_file_or_connection> <wordlist>")
        sys.exit(1)
    try_passwords(sys.argv[1], sys.argv[2])
