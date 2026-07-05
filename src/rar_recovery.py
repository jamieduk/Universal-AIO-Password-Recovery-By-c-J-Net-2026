#!/usr/bin/env python3
import sys
import os
import subprocess

def try_passwords(archive_path, wordlist_path):
    if not os.path.exists(archive_path):
        print(f"ERROR: File not found: {archive_path}")
        sys.exit(1)
    if not os.path.exists(wordlist_path):
        print(f"ERROR: Wordlist not found: {wordlist_path}")
        sys.exit(1)

    with open(wordlist_path, 'r', encoding='utf-8', errors='ignore') as f:
        passwords = [line.rstrip('\n\r') for line in f if line.strip()]

    for pwd in passwords:
        try:
            result = subprocess.run(
                ['unrar', 't', f'-p{pwd}', archive_path],
                capture_output=True, text=True, timeout=30
            )
            if result.returncode == 0 and 'All OK' in result.stdout:
                print(f"PASSWORD FOUND: {pwd}")
                return
        except subprocess.TimeoutExpired:
            continue
        except FileNotFoundError:
            print("ERROR: unrar not found. Install unrar via setup.sh")
            sys.exit(1)
        except Exception:
            continue

    print("PASSWORD NOT FOUND")
    sys.exit(1)

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Usage: rar_recovery.py <rar_file> <wordlist>")
        sys.exit(1)
    try_passwords(sys.argv[1], sys.argv[2])
