#!/usr/bin/env python3
import sys
import os
import subprocess

def try_passwords(pst_path, wordlist_path):
    if not os.path.exists(pst_path):
        print(f"ERROR: File not found: {pst_path}")
        sys.exit(1)
    if not os.path.exists(wordlist_path):
        print(f"ERROR: Wordlist not found: {wordlist_path}")
        sys.exit(1)

    with open(wordlist_path, 'r', encoding='utf-8', errors='ignore') as f:
        passwords = [line.rstrip('\n\r') for line in f if line.strip()]

    for pwd in passwords:
        try:
            result = subprocess.run(
                ['readpst', '-p', pwd, '-o', '/tmp/pst_out', pst_path],
                capture_output=True, timeout=30
            )
            if result.returncode == 0:
                print(f"PASSWORD FOUND: {pwd}")
                return
        except subprocess.TimeoutExpired:
            continue
        except FileNotFoundError:
            print("ERROR: readpst not found. Install libpst-utils via setup.sh")
            sys.exit(1)
        except Exception:
            continue

    print("PASSWORD NOT FOUND")
    sys.exit(1)

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Usage: pst_recovery.py <pst_file> <wordlist>")
        sys.exit(1)
    try_passwords(sys.argv[1], sys.argv[2])
