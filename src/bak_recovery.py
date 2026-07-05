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
                ['7z', 't', file_path, f'-p{pwd}'],
                capture_output=True, text=True, timeout=30
            )
            if result.returncode == 0 and 'Everything is Ok' in result.stdout:
                print(f"PASSWORD FOUND: {pwd}")
                return
        except subprocess.TimeoutExpired:
            continue
        except FileNotFoundError:
            print("ERROR: 7z not found. Install p7zip-full via setup.sh")
            sys.exit(1)
        except Exception:
            continue

    for pwd in passwords:
        try:
            result = subprocess.run(
                ['gpg', '--batch', '--passphrase', pwd, '--decrypt',
                 '--output', '/dev/null', file_path],
                capture_output=True, timeout=30
            )
            if result.returncode == 0:
                print(f"PASSWORD FOUND: {pwd}")
                return
        except subprocess.TimeoutExpired:
            continue
        except Exception:
            continue

    for pwd in passwords:
        try:
            result = subprocess.run(
                ['openssl', 'enc', '-d', '-aes-256-cbc', '-in', file_path,
                 '-pass', f'pass:{pwd}', '-out', '/dev/null'],
                capture_output=True, text=True, timeout=15
            )
            if result.returncode == 0:
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
        print("Usage: bak_recovery.py <bak_file> <wordlist>")
        sys.exit(1)
    try_passwords(sys.argv[1], sys.argv[2])
