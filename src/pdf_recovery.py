#!/usr/bin/env python3
import sys
import os

def try_passwords(pdf_path, wordlist_path):
    if not os.path.exists(pdf_path):
        print(f"ERROR: File not found: {pdf_path}")
        sys.exit(1)
    if not os.path.exists(wordlist_path):
        print(f"ERROR: Wordlist not found: {wordlist_path}")
        sys.exit(1)

    try:
        import pikepdf
    except ImportError:
        print("ERROR: pikepdf not installed. Run setup.sh")
        sys.exit(1)

    with open(wordlist_path, 'r', encoding='utf-8', errors='ignore') as f:
        passwords = [line.rstrip('\n\r') for line in f if line.strip()]

    for pwd in passwords:
        try:
            with pikepdf.open(pdf_path, password=pwd) as pdf:
                print(f"PASSWORD FOUND: {pwd}")
                return
        except pikepdf.PasswordError:
            continue
        except Exception:
            continue

    print("PASSWORD NOT FOUND")
    sys.exit(1)

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Usage: pdf_recovery.py <pdf_file> <wordlist>")
        sys.exit(1)
    try_passwords(sys.argv[1], sys.argv[2])
