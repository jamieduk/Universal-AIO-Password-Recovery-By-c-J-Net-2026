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

    ciphers = [
        ['-aes-256-cbc', '-pbkdf2'],
        ['-aes-256-cbc'],
        ['-aes-128-cbc', '-pbkdf2'],
        ['-aes-128-cbc'],
        ['-des-cbc'],
    ]

    for cipher_args in ciphers:
        for pwd in passwords:
            try:
                cmd = ['openssl', 'enc', '-d'] + cipher_args + ['-in', file_path,
                       '-pass', f'pass:{pwd}', '-out', '/dev/null']
                result = subprocess.run(cmd, capture_output=True, text=True, timeout=15)
                if result.returncode == 0:
                    print(f"PASSWORD FOUND: {pwd}")
                    return
            except subprocess.TimeoutExpired:
                continue
            except FileNotFoundError:
                print("ERROR: openssl not found. Install openssl via setup.sh")
                sys.exit(1)
            except Exception:
                continue

    print("PASSWORD NOT FOUND")
    sys.exit(1)

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Usage: openssl_recovery.py <enc_file> <wordlist>")
        sys.exit(1)
    try_passwords(sys.argv[1], sys.argv[2])
