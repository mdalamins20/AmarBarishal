import firebase_admin
from firebase_admin import credentials, firestore
import os

try:
    cred = credentials.Certificate(os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json'))
    firebase_admin.initialize_app(cred)
except ValueError:
    pass

db = firestore.client()

def dedup_doctors():
    items_ref = db.collection('categories').document('doctor').collection('items')
    all_docs = items_ref.stream()
    
    seen_names = set()
    deleted_count = 0
    kept_count = 0
    
    for doc in all_docs:
        data = doc.to_dict()
        name = data.get('name')
        specialty = data.get('specialty')
        
        # Unique identifier
        key = f"{name}_{specialty}"
        
        if key in seen_names:
            doc.reference.delete()
            deleted_count += 1
        else:
            seen_names.add(key)
            kept_count += 1
            
    print(f"Kept {kept_count} unique doctors.")
    print(f"Deleted {deleted_count} duplicate doctors.")

if __name__ == '__main__':
    dedup_doctors()
