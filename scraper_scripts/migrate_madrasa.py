import firebase_admin
from firebase_admin import credentials, firestore
import os

try:
    cred = credentials.Certificate(os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json'))
    firebase_admin.initialize_app(cred)
except ValueError:
    pass

db = firestore.client()

def migrate_madrasa():
    school_ref = db.collection('categories').document('schoolCollege').collection('items')
    madrasa_ref = db.collection('categories').document('madrasa').collection('items')
    
    docs = school_ref.stream()
    
    keywords = ['মাদ্রাসা', 'মাদরাসা', 'madrasa', 'madrasha', 'fazil', 'kamil', 'alim', 'dakhil']
    
    count = 0
    for doc in docs:
        data = doc.to_dict()
        name = str(data.get('name', '')).lower()
        
        is_madrasa = any(kw in name for kw in keywords)
        
        if is_madrasa:
            # Add to madrasa category
            madrasa_ref.document(doc.id).set(data)
            # Remove from schoolCollege category
            school_ref.document(doc.id).delete()
            count += 1
            
    print(f"\nSuccessfully migrated {count} madrasas.")

if __name__ == '__main__':
    migrate_madrasa()
