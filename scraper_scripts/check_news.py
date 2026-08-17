import firebase_admin
from firebase_admin import credentials, firestore
import os

try:
    cred = credentials.Certificate(os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json'))
    firebase_admin.initialize_app(cred)
except ValueError:
    pass
    
db = firestore.client()
collection_ref = db.collection('categories').document('newspaper').collection('items')
docs = collection_ref.stream()

count = 0
sources = set()
for doc in docs:
    data = doc.to_dict()
    sources.add(data.get('source', 'Unknown'))
    count += 1

print(f"Total news items: {count}")
print(f"Sources found: {sources}")
