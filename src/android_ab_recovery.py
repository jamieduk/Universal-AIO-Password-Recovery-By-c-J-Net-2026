#!/usr/bin/env python3
import sys
import os
import subprocess

def try_passwords(ab_path, wordlist_path):
    if not os.path.exists(ab_path):
        print(f"ERROR: File not found: {ab_path}")
        sys.exit(1)
    if not os.path.exists(wordlist_path):
        print(f"ERROR: Wordlist not found: {wordlist_path}")
        sys.exit(1)

    with open(wordlist_path, 'r', encoding='utf-8', errors='ignore') as f:
        passwords = [line.rstrip('\n\r') for line in f if line.strip()]

    for pwd in passwords:
        try:
            result = subprocess.run(
                ['abe', 'unpack', ab_path, '/tmp/ab_test.tar', pwd],
                capture_output=True, timeout=30
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
                ['dd', 'if=' + ab_path, 'bs=24', 'skip=1'],
                capture_output=True, timeout=5
            )
            if result.returncode == 0:
                pass
        except Exception:
            pass

    print("PASSWORD NOT FOUND")
    sys.exit(1)

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Usage: android_ab_recovery.py <ab_file> <wordlist>")
        sys.exit(1)
    try_passwords(sys.argv[1], sys.argv[2])
