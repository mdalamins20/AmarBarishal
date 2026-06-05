import requests
from bs4 import BeautifulSoup
import io
import pdfplumber
import urllib3
urllib3.disable_warnings()

url = "https://barisal.gov.bd/pages/static-pages/697876a9c4774958d7c4389b"
print(f"Fetching {url}")
response = requests.get(url, verify=False)
soup = BeautifulSoup(response.content, 'html.parser')

pdf_links = []
for link in soup.find_all('a'):
    href = link.get('href')
    if href and href.endswith('.pdf'):
        if not href.startswith('http'):
            href = "https://barisal.gov.bd" + href
        pdf_links.append(href)

print(f"Found PDF links: {pdf_links}")

if pdf_links:
    pdf_url = pdf_links[0]
    print(f"Downloading {pdf_url}")
    res = requests.get(pdf_url, verify=False)
    pdf_file = io.BytesIO(res.content)
    
    with pdfplumber.open(pdf_file) as pdf:
        print(f"PDF pages: {len(pdf.pages)}")
        first_page = pdf.pages[0]
        tables = first_page.extract_tables()
        if tables:
            print("First table, first 3 rows:")
            for row in tables[0][:3]:
                print(row)
        else:
            print("No tables found on first page.")
