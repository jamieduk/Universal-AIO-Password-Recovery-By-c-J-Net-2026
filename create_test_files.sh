#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$SCRIPT_DIR/test"
PASSWORD="test"

GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

mkdir -p "$TEST_DIR"

echo -e "${GREEN}[*] Creating test files with password: $PASSWORD${NC}"
echo ""

echo -e "${GREEN}[1] Creating test.zip ...${NC}"
echo "test content" > /tmp/test_content.txt
zip -P "$PASSWORD" -j "$TEST_DIR/test.zip" /tmp/test_content.txt 2>/dev/null
rm -f /tmp/test_content.txt

echo -e "${GREEN}[2] Creating test.pdf ...${NC}"
python3 -c "
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import letter
c = canvas.Canvas('$TEST_DIR/test_unencrypted.pdf', pagesize=letter)
c.drawString(100, 750, 'Test PDF')
c.save()
" 2>/dev/null || {
    python3 -c "
from fpdf import FPDF
pdf = FPDF()
pdf.add_page()
pdf.set_font('Arial', size=12)
pdf.cell(200, 10, txt='Test PDF', ln=True)
pdf.output('$TEST_DIR/test_unencrypted.pdf')
" 2>/dev/null || {
    echo "test pdf content" > /tmp/test_pdf.txt
    libreoffice --headless --convert-to pdf --outdir "$TEST_DIR" /tmp/test_pdf.txt 2>/dev/null
    mv "$TEST_DIR/test_pdf.pdf" "$TEST_DIR/test_unencrypted.pdf" 2>/dev/null || true
    rm -f /tmp/test_pdf.txt
}
}
python3 -c "
import pikepdf
pdf = pikepdf.open('$TEST_DIR/test_unencrypted.pdf')
pdf.save('$TEST_DIR/test.pdf', encryption=pikepdf.Encryption(owner='$PASSWORD', user='$PASSWORD', R=4))
" 2>/dev/null
rm -f "$TEST_DIR/test_unencrypted.pdf"

echo -e "${GREEN}[3] Creating test.7z ...${NC}"
echo "test content" > /tmp/test_7z.txt
7z a -p"$PASSWORD" -mhe=on "$TEST_DIR/test.7z" /tmp/test_7z.txt 2>/dev/null
rm -f /tmp/test_7z.txt

echo -e "${GREEN}[4] Creating test.rar ...${NC}"
echo "test content" > /tmp/test_rar.txt
rar a -hp"$PASSWORD" "$TEST_DIR/test.rar" /tmp/test_rar.txt 2>/dev/null
rm -f /tmp/test_rar.txt

echo -e "${GREEN}[5] Creating test.docx ...${NC}"
python3 -c "
from docx import Document
doc = Document()
doc.add_paragraph('Test document')
doc.save('$TEST_DIR/test_unencrypted.docx')
" 2>/dev/null || {
    echo "test doc content" > /tmp/test_doc.txt
    libreoffice --headless --convert-to docx --outdir "$TEST_DIR" /tmp/test_doc.txt 2>/dev/null
    mv "$TEST_DIR/test_doc.docx" "$TEST_DIR/test_unencrypted.docx" 2>/dev/null || true
    rm -f /tmp/test_doc.txt
}
python3 -c "
import msoffcrypto
import io
with open('$TEST_DIR/test_unencrypted.docx', 'rb') as f:
    office_file = msoffcrypto.OfficeFile(f)
    office_file.load_key(password='$PASSWORD', verify=False)
    encrypted = io.BytesIO()
    office_file.encrypt(encrypted, password='$PASSWORD')
    with open('$TEST_DIR/test.docx', 'wb') as out:
        out.write(encrypted.getvalue())
" 2>/dev/null || {
    python3 -c "
import msoffcrypto
with open('$TEST_DIR/test_unencrypted.docx', 'rb') as f:
    encrypted = msoffcrypto.encrypt(f, '$PASSWORD')
    with open('$TEST_DIR/test.docx', 'wb') as out:
        out.write(encrypted.read())
" 2>/dev/null || true
}
rm -f "$TEST_DIR/test_unencrypted.docx"

echo -e "${GREEN}[6] Creating test.xlsx ...${NC}"
python3 -c "
from openpyxl import Workbook
wb = Workbook()
ws = wb.active
ws['A1'] = 'Test'
wb.save('$TEST_DIR/test_unencrypted.xlsx')
" 2>/dev/null || {
    echo "test xls content" > /tmp/test_xls.txt
    libreoffice --headless --convert-to xlsx --outdir "$TEST_DIR" /tmp/test_xls.txt 2>/dev/null
    mv "$TEST_DIR/test_xls.xlsx" "$TEST_DIR/test_unencrypted.xlsx" 2>/dev/null || true
    rm -f /tmp/test_xls.txt
}
python3 -c "
import msoffcrypto
import io
with open('$TEST_DIR/test_unencrypted.xlsx', 'rb') as f:
    office_file = msoffcrypto.OfficeFile(f)
    office_file.load_key(password='$PASSWORD', verify=False)
    encrypted = io.BytesIO()
    office_file.encrypt(encrypted, password='$PASSWORD')
    with open('$TEST_DIR/test.xlsx', 'wb') as out:
        out.write(encrypted.getvalue())
" 2>/dev/null || true
rm -f "$TEST_DIR/test_unencrypted.xlsx"

echo -e "${GREEN}[7] Creating test.pptx ...${NC}"
python3 -c "
from pptx import Presentation
prs = Presentation()
slide = prs.slides.add_slide(prs.slide_layouts[0])
slide.shapes.title.text = 'Test'
prs.save('$TEST_DIR/test_unencrypted.pptx')
" 2>/dev/null || {
    echo "test ppt content" > /tmp/test_ppt.txt
    libreoffice --headless --convert-to pptx --outdir "$TEST_DIR" /tmp/test_ppt.txt 2>/dev/null
    mv "$TEST_DIR/test_ppt.pptx" "$TEST_DIR/test_unencrypted.pptx" 2>/dev/null || true
    rm -f /tmp/test_ppt.txt
}
python3 -c "
import msoffcrypto
import io
with open('$TEST_DIR/test_unencrypted.pptx', 'rb') as f:
    office_file = msoffcrypto.OfficeFile(f)
    office_file.load_key(password='$PASSWORD', verify=False)
    encrypted = io.BytesIO()
    office_file.encrypt(encrypted, password='$PASSWORD')
    with open('$TEST_DIR/test.pptx', 'wb') as out:
        out.write(encrypted.getvalue())
" 2>/dev/null || true
rm -f "$TEST_DIR/test_unencrypted.pptx"

echo -e "${GREEN}[8] Creating test.odt ...${NC}"
echo "test odt content" > /tmp/test_odt.txt
libreoffice --headless --convert-to odt --outdir "$TEST_DIR" /tmp/test_odt.txt 2>/dev/null
mv "$TEST_DIR/test_odt.odt" "$TEST_DIR/test_unencrypted.odt" 2>/dev/null || true
rm -f /tmp/test_odt.txt
libreoffice --headless --infilter="writer8" --password "$PASSWORD" \
    --convert-to odt --outdir "$TEST_DIR" "$TEST_DIR/test_unencrypted.odt" 2>/dev/null || {
    cp "$TEST_DIR/test_unencrypted.odt" "$TEST_DIR/test.odt" 2>/dev/null || true
}
rm -f "$TEST_DIR/test_unencrypted.odt"

echo -e "${GREEN}[9] Creating test.ods ...${NC}"
echo -e "A\tB\n1\t2" > /tmp/test_ods.csv
libreoffice --headless --convert-to ods --outdir "$TEST_DIR" /tmp/test_ods.csv 2>/dev/null
mv "$TEST_DIR/test_ods.ods" "$TEST_DIR/test_unencrypted.ods" 2>/dev/null || true
rm -f /tmp/test_ods.csv
cp "$TEST_DIR/test_unencrypted.ods" "$TEST_DIR/test.ods" 2>/dev/null || true
rm -f "$TEST_DIR/test_unencrypted.ods"

echo -e "${GREEN}[10] Creating test.odp ...${NC}"
echo "test odp content" > /tmp/test_odp.txt
libreoffice --headless --convert-to odp --outdir "$TEST_DIR" /tmp/test_odp.txt 2>/dev/null
mv "$TEST_DIR/test_odp.odp" "$TEST_DIR/test_unencrypted.odp" 2>/dev/null || true
rm -f /tmp/test_odp.txt
cp "$TEST_DIR/test_unencrypted.odp" "$TEST_DIR/test.odp" 2>/dev/null || true
rm -f "$TEST_DIR/test_unencrypted.odp"

echo -e "${GREEN}[11] Creating test.enc (OpenSSL AES-256-CBC) ...${NC}"
echo "test openssl content" | openssl enc -aes-256-cbc -pass pass:"$PASSWORD" -pbkdf2 -out "$TEST_DIR/test.enc" 2>/dev/null

echo -e "${GREEN}[12] Creating test.iso ...${NC}"
mkdir -p /tmp/test_iso_dir
echo "test iso content" > /tmp/test_iso_dir/readme.txt
genisoimage -o "$TEST_DIR/test.iso" /tmp/test_iso_dir 2>/dev/null || {
    mkisofs -o "$TEST_DIR/test.iso" /tmp/test_iso_dir 2>/dev/null || {
        dd if=/dev/zero of="$TEST_DIR/test.iso" bs=1M count=1 2>/dev/null
    }
}
rm -rf /tmp/test_iso_dir

echo -e "${GREEN}[13] Creating test.tar.gz.gpg ...${NC}"
echo "test gpg content" > /tmp/test_gpg.txt
tar czf /tmp/test_gpg.tar.gz /tmp/test_gpg.txt 2>/dev/null
gpg --batch --yes --passphrase "$PASSWORD" --symmetric --cipher-algo AES256 \
    -o "$TEST_DIR/test.tar.gz.gpg" /tmp/test_gpg.tar.gz 2>/dev/null
rm -f /tmp/test_gpg.txt /tmp/test_gpg.tar.gz

echo -e "${GREEN}[14] Creating test.pgp ...${NC}"
echo "test pgp content" > /tmp/test_pgp.txt
gpg --batch --yes --passphrase "$PASSWORD" --symmetric --cipher-algo AES256 \
    -o "$TEST_DIR/test.pgp" /tmp/test_pgp.txt 2>/dev/null
rm -f /tmp/test_pgp.txt

echo -e "${GREEN}[15] Creating test.pem (encrypted private key) ...${NC}"
openssl genpkey -algorithm RSA -out /tmp/test_key.pem -pass pass:"$PASSWORD" \
    -aes256 2>/dev/null
mv /tmp/test_key.pem "$TEST_DIR/test.pem" 2>/dev/null

echo -e "${GREEN}[16] Creating test.p12 ...${NC}"
openssl req -x509 -newkey rsa:2048 -keyout /tmp/test_p12_key.pem \
    -out /tmp/test_p12_cert.pem -days 365 -nodes \
    -subj "/C=US/ST=State/L=City/O=Org/CN=test" 2>/dev/null
openssl pkcs12 -export -in /tmp/test_p12_cert.pem -inkey /tmp/test_p12_key.pem \
    -out "$TEST_DIR/test.p12" -passout pass:"$PASSWORD" 2>/dev/null
rm -f /tmp/test_p12_key.pem /tmp/test_p12_cert.pem

echo -e "${GREEN}[17] Creating test.kdbx ...${NC}"
python3 -c "
from pykeepass import PyKeePass
kp = PyKeePass('$TEST_DIR/test.kdbx', password='$PASSWORD')
group = kp.add_group(kp.root_group, 'TestGroup')
kp.add_entry(group, 'TestEntry', 'testuser', 'testpass')
kp.save()
" 2>/dev/null || echo "  (pykeepass may not be installed - skipping)"

echo -e "${GREEN}[18] Creating test.sqlite ...${NC}"
sqlite3 "$TEST_DIR/test.sqlite" "CREATE TABLE test(id INTEGER PRIMARY KEY, data TEXT); INSERT INTO test VALUES(1,'test');" 2>/dev/null

echo -e "${GREEN}[19] Creating test.bak ...${NC}"
echo "test bak content" > "$TEST_DIR/test.bak"

echo -e "${GREEN}[20] Creating test.docm ...${NC}"
python3 -c "
from docx import Document
doc = Document()
doc.add_paragraph('Test macro document')
doc.save('$TEST_DIR/test_unencrypted.docm')
" 2>/dev/null || {
    echo "test docm content" > /tmp/test_docm.txt
    libreoffice --headless --convert-to docx --outdir "$TEST_DIR" /tmp/test_docm.txt 2>/dev/null
    mv "$TEST_DIR/test_docm.docx" "$TEST_DIR/test_unencrypted.docm" 2>/dev/null || true
    rm -f /tmp/test_docm.txt
}
python3 -c "
import msoffcrypto
import io
with open('$TEST_DIR/test_unencrypted.docm', 'rb') as f:
    office_file = msoffcrypto.OfficeFile(f)
    office_file.load_key(password='$PASSWORD', verify=False)
    encrypted = io.BytesIO()
    office_file.encrypt(encrypted, password='$PASSWORD')
    with open('$TEST_DIR/test.docm', 'wb') as out:
        out.write(encrypted.getvalue())
" 2>/dev/null || true
rm -f "$TEST_DIR/test_unencrypted.docm"

echo -e "${GREEN}[21] Creating test.epub ...${NC}"
python3 -c "
import zipfile, os
os.makedirs('/tmp/epub_tmp/META-INF', exist_ok=True)
with open('/tmp/epub_tmp/mimetype', 'w') as f:
    f.write('application/epub+zip')
with open('/tmp/epub_tmp/META-INF/container.xml', 'w') as f:
    f.write('<?xml version=\"1.0\"?><container version=\"1.0\" xmlns=\"urn:oasis:names:tc:opendocument:xmlns:container\"><rootfiles><rootfile full-path=\"content.opf\" media-type=\"application/oebps-package+xml\"/></rootfiles></container>')
with open('/tmp/epub_tmp/content.opf', 'w') as f:
    f.write('<?xml version=\"1.0\"?><package version=\"2.0\" xmlns=\"http://www.idpf.org/2007/opf\"><metadata><dc:title xmlns:dc=\"http://purl.org/dc/elements/1.1/\">Test</dc:title></metadata><manifest><item id=\"ncx\" href=\"toc.ncx\" media-type=\"application/x-dtbncx+xml\"/><item id=\"content\" href=\"content.html\" media-type=\"application/xhtml+xml\"/></manifest><spine toc=\"ncx\"><itemref idref=\"content\"/></spine></package>')
with open('/tmp/epub_tmp/toc.ncx', 'w') as f:
    f.write('<?xml version=\"1.0\"?><ncx xmlns=\"http://www.daisy.org/z3986/2005/ncx/\"><head><meta name=\"dtb:uid\" content=\"test\"/></head><docTitle><text>Test</text></docTitle><navMap><navPoint id=\"navpoint-1\"><navLabel><text>Start</text></navLabel><content src=\"content.html\"/></navPoint></navMap></ncx>')
with open('/tmp/epub_tmp/content.html', 'w') as f:
    f.write('<html><body><p>Test EPUB</p></body></html>')
with zipfile.ZipFile('$TEST_DIR/test.epub', 'w') as zf:
    zf.write('/tmp/epub_tmp/mimetype', 'mimetype', zipfile.ZIP_STORED)
    for root, dirs, files in os.walk('/tmp/epub_tmp'):
        for fn in files:
            if fn == 'mimetype':
                continue
            fp = os.path.join(root, fn)
            an = os.path.relpath(fp, '/tmp/epub_tmp')
            zf.write(fp, an)
" 2>/dev/null || echo "  (EPUB creation failed - skipping)"
rm -rf /tmp/epub_tmp

echo ""
echo -e "${GREEN}[*] Test files created in: $TEST_DIR${NC}"
ls -la "$TEST_DIR/"
