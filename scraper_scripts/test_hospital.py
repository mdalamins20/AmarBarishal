import requests, base64
from bs4 import BeautifulSoup

url = 'https://barishal.gov.bd/pages/static-pages/69789b9135ce18e1c066f1c8'
r = requests.get(url, verify=True)
soup = BeautifulSoup(r.content, 'html.parser')

tables = soup.find_all('table')
for rt in soup.find_all('rt-renderer'):
    encoded = rt.get('encoded-content')
    if encoded:
        try:
            decoded = base64.b64decode(encoded).decode('utf-8')
            soup2 = BeautifulSoup(decoded, 'html.parser')
            tables.extend(soup2.find_all('table'))
        except:
            pass

for table in tables:
    for tr in table.find_all('tr')[:3]:
        print([td.get_text(strip=True) for td in tr.find_all(['th', 'td'])])
