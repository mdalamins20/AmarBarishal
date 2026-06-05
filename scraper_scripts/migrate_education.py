import firebase_admin
from firebase_admin import credentials, firestore
import os

try:
    cred = credentials.Certificate(os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json'))
    firebase_admin.initialize_app(cred)
except ValueError:
    pass

db = firestore.client()

def migrate_education():
    school_ref = db.collection('categories').document('schoolCollege').collection('items')
    primary_ref = db.collection('categories').document('primarySchool').collection('items')
    high_ref = db.collection('categories').document('highSchool').collection('items')
    college_ref = db.collection('categories').document('college').collection('items')
    uni_ref = db.collection('categories').document('university').collection('items')
    
    docs = school_ref.stream()
    
    primary_keywords = ['প্রাথমিক', 'primary', 'কিন্ডারগার্টেন', 'kindergarten']
    uni_keywords = ['বিশ্ববিদ্যালয়', 'university', 'ভার্সিটি', 'varsity', 'institute of technology']
    college_keywords = ['কলেজ', 'college']
    high_keywords = ['উচ্চ', 'মাধ্যমিক', 'হাই', 'high', 'secondary', 'বিদ্যালয়', 'school', 'একাডেমি', 'academy']
    
    counts = {'primary': 0, 'high': 0, 'college': 0, 'uni': 0, 'unknown': 0}
    
    for doc in docs:
        data = doc.to_dict()
        name = str(data.get('name', '')).lower()
        
        category_ref = None
        
        # Priority: University > Primary > College > High School
        if any(kw in name for kw in uni_keywords):
            category_ref = uni_ref
            counts['uni'] += 1
        elif any(kw in name for kw in primary_keywords):
            category_ref = primary_ref
            counts['primary'] += 1
        elif any(kw in name for kw in college_keywords):
            category_ref = college_ref
            counts['college'] += 1
        elif any(kw in name for kw in high_keywords):
            category_ref = high_ref
            counts['high'] += 1
        else:
            # Default to high school if it just says school or nothing specific but was in this category
            category_ref = high_ref
            counts['unknown'] += 1
            
        if category_ref:
            category_ref.document(doc.id).set(data)
            school_ref.document(doc.id).delete()
            
    # Also delete the main category doc to clean up
    try:
        db.collection('categories').document('schoolCollege').delete()
    except Exception:
        pass
        
    # We do not print names to avoid unicode errors in subprocess
    print(f"Successfully migrated data. Primary: {counts['primary']}, High: {counts['high']}, College: {counts['college']}, Uni: {counts['uni']}, Unknown (High): {counts['unknown']}")

if __name__ == '__main__':
    migrate_education()
