import firebase_admin
from firebase_admin import credentials, firestore
import os

try:
    cred = credentials.Certificate(os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json'))
    firebase_admin.initialize_app(cred)
except ValueError:
    pass

db = firestore.client()

def fix_primary_schools():
    high_ref = db.collection('categories').document('highSchool').collection('items')
    primary_ref = db.collection('categories').document('primarySchool').collection('items')
    
    docs = high_ref.stream()
    
    # Keywords indicating a primary school that might have slipped into high school
    primary_keywords = [
        'সঃপ্রাঃবিঃ', 'সঃ প্রাঃ বিঃ', 'সপ্রাবি', 'স.প্রা.বি.', 'স. প্রা. বি.', 
        'সঃপ্রাঃ', 'প্রাথমিক', 'স.প্রা.বি', 'সঃ প্রাঃ'
    ]
    
    count = 0
    for doc in docs:
        data = doc.to_dict()
        name = str(data.get('name', '')).lower()
        
        # Check if it's actually a primary school
        is_primary = any(kw in name for kw in primary_keywords)
        
        # Explicitly ignore if it says "উচ্চ" or "মাধ্যমিক" unless we are sure it's just primary
        is_high = 'উচ্চ' in name or 'মাধ্যমিক' in name or 'high' in name
        
        if is_primary and not is_high:
            # Move to primary school
            primary_ref.document(doc.id).set(data)
            # Delete from high school
            high_ref.document(doc.id).delete()
            count += 1
            
    print(f"Successfully moved {count} miscategorized primary schools from highSchool to primarySchool.")

if __name__ == '__main__':
    fix_primary_schools()
