#!/usr/bin/env python3
import sys
import os

def try_passwords(file_path, wordlist_path):
    if not os.path.exists(file_path):
        print(f"ERROR: File not found: {file_path}")
        sys.exit(1)
    if not os.path.exists(wordlist_path):
        print(f"ERROR: Wordlist not found: {wordlist_path}")
        sys.exit(1)

    try:
        import msoffcrypto
    except ImportError:
        print("ERROR: msoffcrypto not installed. Run setup.sh")
        sys.exit(1)

    with open(wordlist_path, 'r', encoding='utf-8', errors='ignore') as f:
        passwords = [line.rstrip('\n\r') for line in f if line.strip()]

    for pwd in passwords:
        try:
            with open(file_path, 'rb') as fh:
                office_file = msoffcrypto.OfficeFile(fh)
                office_file.load_key(password=pwd)
                office_file.decrypt(open('/dev/null', 'wb'))
                print(f"PASSWORD FOUND: {pwd}")
                return
        except Exception:
            continue

    print("PASSWORD NOT FOUND")
    sys.exit(1)

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Usage: office_macro_recovery.py <office_macro_file> <wordlist>")
        sys.exit(1)
    try_passwords(sys.argv[1], sys.argv[2])
