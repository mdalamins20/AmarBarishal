import urllib.request
import xml.etree.ElementTree as ET

url = "https://barishalcrimenews.com/feed/"
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
try:
    with urllib.request.urlopen(req) as response:
        xml_data = response.read()
        root = ET.fromstring(xml_data)
        item = root.find('.//item')
        if item is not None:
            print("=== RAW ITEM XML ===")
            print(ET.tostring(item, encoding='unicode'))
        else:
            print("No items found.")
except Exception as e:
    print("Error:", e)
