import urllib.request
import json

try:
    req = urllib.request.urlopen("http://127.0.0.1:8000/api/news")
    data = req.read().decode('utf-8')
    parsed = json.loads(data)
    print("STATUS CODE: 200")
    print("DATA LENGTH:", len(parsed.get("data", [])))
    print("JSON RESPONSE:", json.dumps(parsed, indent=2, ensure_ascii=False))
except Exception as e:
    print("ERROR:", e)
