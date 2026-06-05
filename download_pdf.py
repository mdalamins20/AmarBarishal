import urllib.request
url = 'https://objectstorage.ap-dcc-gazipur-1.oraclecloud15.com/n/axvjbnqprylg/b/V2Ministry/o/office-pbs1-barisal/2026/3/bf0b2d8b-ae2f-4a61-92ac-ce8e1c19de6b.pdf'
urllib.request.urlretrieve(url, 'pbs1.pdf')
print("Downloaded pbs1.pdf")
