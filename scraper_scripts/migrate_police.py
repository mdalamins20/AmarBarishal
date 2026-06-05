import firebase_admin
from firebase_admin import credentials, firestore
import os

try:
    cred = credentials.Certificate(os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json'))
    firebase_admin.initialize_app(cred)
except ValueError:
    pass

db = firestore.client()

def migrate_police_data():
    items_ref = db.collection('categories').document('police').collection('items')
    docs = items_ref.stream()
    
    updated_count = 0
    for doc in docs:
        data = doc.to_dict()
        
        updates = {}
        # Delete unions and paurashavas
        if 'unions' in data:
            updates['unions'] = firestore.DELETE_FIELD
        if 'paurashavas' in data:
            updates['paurashavas'] = firestore.DELETE_FIELD
            
        # Migrate thanas
        if 'thanas' in data and isinstance(data['thanas'], list):
            new_thanas = []
            for t in data['thanas']:
                if isinstance(t, str):
                    new_thanas.append({
                        "name": t,
                        "oc_name": "অফিসার ইনচার্জ (ওসি)",
                        "phone": "01XXXXXX",
                        "address": data.get('name', '') + ", বরিশাল"
                    })
                elif isinstance(t, dict):
                    # Already migrated
                    new_thanas.append(t)
            
            if new_thanas:
                updates['thanas'] = new_thanas
                
        if updates:
            doc.reference.update(updates)
            updated_count += 1
            
    print(f"Successfully migrated {updated_count} police upazila items.")

if __name__ == '__main__':
    migrate_police_data()
