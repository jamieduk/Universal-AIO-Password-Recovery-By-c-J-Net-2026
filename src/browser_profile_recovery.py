#!/usr/bin/env python3
import sys
import os
import subprocess
import sqlite3
import json
import base64
import hashlib
import tempfile
import shutil

def try_firefox_master(profile_path, wordlist_path):
    key4_path = os.path.join(profile_path, 'key4.db')
    logins_path = os.path.join(profile_path, 'logins.json')

    if not os.path.exists(key4_path):
        return False

    with open(wordlist_path, 'r', encoding='utf-8', errors='ignore') as f:
        passwords = [line.rstrip('\n\r') for line in f if line.strip()]

    tmp_db = tempfile.mktemp(suffix='.db')
    shutil.copy2(key4_path, tmp_db)

    try:
        conn = sqlite3.connect(tmp_db)
        c = conn.cursor()
        c.execute("SELECT item1, item2 FROM metadata WHERE id = 'password'")
        row = c.fetchone()
        conn.close()

        if not row:
            return False

        global_salt = row[0]
        enc_data = row[1]

        for pwd in passwords:
            try:
                key = hashlib.pbkdf2_hmac('sha256', pwd.encode('utf-8'), global_salt, 1, dklen=32)
                iv = enc_data[-16:]
                ciphertext = enc_data[:-16]
                from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
                from cryptography.hazmat.backends import default_backend
                cipher = Cipher(algorithms.AES(key), modes.CBC(iv), backend=default_backend())
                decryptor = cipher.decryptor()
                decrypted = decryptor.update(ciphertext) + decryptor.finalize()
                if decrypted and len(decrypted) > 0:
                    print(f"PASSWORD FOUND: {pwd}")
                    return True
            except Exception:
                continue
    finally:
        if os.path.exists(tmp_db):
            os.unlink(tmp_db)

    return False

def try_passwords(target_path, wordlist_path):
    if not os.path.exists(target_path):
        print(f"ERROR: Path not found: {target_path}")
        sys.exit(1)
    if not os.path.exists(wordlist_path):
        print(f"ERROR: Wordlist not found: {wordlist_path}")
        sys.exit(1)

    if os.path.isdir(target_path):
        if try_firefox_master(target_path, wordlist_path):
            return

    print("PASSWORD NOT FOUND")
    sys.exit(1)

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Usage: browser_profile_recovery.py <profile_path> <wordlist>")
        sys.exit(1)
    try_passwords(sys.argv[1], sys.argv[2])
