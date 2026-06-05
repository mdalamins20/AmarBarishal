import firebase_admin
from firebase_admin import credentials, firestore
import os
import json

try:
    cred = credentials.Certificate(os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json'))
    firebase_admin.initialize_app(cred)
except ValueError:
    pass

db = firestore.client()

def test_db():
    res = []
    for cat in ['primarySchool', 'highSchool', 'college', 'university']:
        docs = db.collection('categories').document(cat).collection('items').stream()
        for d in docs:
            data = d.to_dict()
            if 'বারহাজার' in str(data):
                res.append(data)
    with open('test_db.json', 'w', encoding='utf-8') as f:
        json.dump(res, f, ensure_ascii=False, indent=2)

if __name__ == '__main__':
    test_db()
