#!/usr/bin/env python3
import sys
import os
import zipfile

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
            with zipfile.ZipFile(file_path, 'r') as zf:
                zf.extractall(pwd=pwd.encode('utf-8'))
                print(f"PASSWORD FOUND: {pwd}")
                return
        except RuntimeError:
            continue
        except zipfile.BadZipFile:
            print("ERROR: Not a valid EPUB/ZIP file or corrupted")
            sys.exit(1)
        except Exception:
            continue

    print("PASSWORD NOT FOUND")
    sys.exit(1)

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Usage: epub_recovery.py <epub_file> <wordlist>")
        sys.exit(1)
    try_passwords(sys.argv[1], sys.argv[2])
