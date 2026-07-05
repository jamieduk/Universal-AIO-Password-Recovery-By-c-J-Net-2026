#!/usr/bin/env python3
import sys
import os
import zipfile
import hashlib
import base64
import xml.etree.ElementTree as ET
from Crypto.Cipher import AES
from Crypto.Util.Padding import unpad

def try_passwords(file_path, wordlist_path):
    if not os.path.exists(file_path):
        print(f"ERROR: File not found: {file_path}")
        sys.exit(1)
    if not os.path.exists(wordlist_path):
        print(f"ERROR: Wordlist not found: {wordlist_path}")
        sys.exit(1)

    try:
        with zipfile.ZipFile(file_path, 'r') as zf:
            manifest_xml = zf.read('META-INF/manifest.xml')
    except Exception:
        print("ERROR: Cannot read ODF file")
        sys.exit(1)

    ns = {
        'manifest': 'urn:oasis:names:tc:opendocument:xmlns:manifest:1.0',
    }
    root = ET.fromstring(manifest_xml)
    enc_data = root.find('.//manifest:encryption-data', ns)
    if enc_data is None:
        print("ERROR: File is not encrypted")
        sys.exit(1)

    checksum_b64 = enc_data.get('{%s}checksum' % ns['manifest'])
    expected_checksum = base64.b64decode(checksum_b64)

    algo = enc_data.find('manifest:algorithm', ns)
    iv_b64 = algo.get('{%s}initialisation-vector' % ns['manifest'])
    iv = base64.b64decode(iv_b64)

    kdf = enc_data.find('manifest:key-derivation', ns)
    salt_b64 = kdf.get('{%s}salt' % ns['manifest'])
    salt = base64.b64decode(salt_b64)
    iterations = int(kdf.get('{%s}iteration-count' % ns['manifest']))
    key_size = int(kdf.get('{%s}key-size' % ns['manifest']))

    try:
        with zipfile.ZipFile(file_path, 'r') as zf:
            encrypted_content = zf.read('content.xml')
    except Exception:
        print("ERROR: Cannot read encrypted content")
        sys.exit(1)

    with open(wordlist_path, 'r', encoding='utf-8', errors='ignore') as f:
        passwords = [line.rstrip('\n\r') for line in f if line.strip()]

    for pwd in passwords:
        try:
            key = hashlib.pbkdf2_hmac('sha256', pwd.encode('utf-8'), salt, iterations, dklen=key_size)
            cipher = AES.new(key, AES.MODE_CBC, iv)
            decrypted = unpad(cipher.decrypt(encrypted_content), AES.block_size)
            checksum = hashlib.sha256(decrypted).digest()
            if checksum == expected_checksum:
                print(f"PASSWORD FOUND: {pwd}")
                return
        except Exception:
            continue

    print("PASSWORD NOT FOUND")
    sys.exit(1)

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Usage: odf_recovery.py <odf_file> <wordlist>")
        sys.exit(1)
    try_passwords(sys.argv[1], sys.argv[2])
