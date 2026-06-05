import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import api
import time

def upload_all_data():
    print("Connecting to Firebase...")
    import os
    script_dir = os.path.dirname(os.path.abspath(__file__))
    key_path = os.path.join(script_dir, 'serviceAccountKey.json')
    try:
        cred = credentials.Certificate(key_path)
        firebase_admin.initialize_app(cred)
        db = firestore.client()
        print("Connected successfully!")
    except FileNotFoundError:
        print("---------------------------------------------------")
        print("ERROR: serviceAccountKey.json not found!")
        print("---------------------------------------------------")
        print("Please download the Service Account Key from:")
        print("Firebase Console -> Project Settings -> Service accounts -> Generate new private key")
        print("Place the downloaded file in the 'scraper_scripts' folder and rename it to 'serviceAccountKey.json'.")
        print("Then run this script again.")
        print("---------------------------------------------------")
        return
        
    categories_to_scrape = ['schoolCollege', 'hospital']
    
    for cat_id in categories_to_scrape:
        print(f"Scraping data for category: {cat_id} (this may take a minute)...")
        response = api.get_category_items(cat_id)
        items = response.get("data", [])
        
        if not items:
            print(f"No data found for {cat_id}. Skipping...")
            continue
            
        print(f"Found {len(items)} items. Uploading to Firestore: categories/{cat_id}/items...")
        
        # Uploading in batches to avoid Firestore limits
        collection_ref = db.collection('categories').document(cat_id).collection('items')
        
        # Using a list to split into chunks of 500 (Firestore batch limit)
        chunk_size = 400
        for i in range(0, len(items), chunk_size):
            chunk = items[i:i+chunk_size]
            batch = db.batch()
            
            for item in chunk:
                # Use a sanitized name as the document ID to prevent duplicates
                # or fallback to auto-id if name is not suitable
                doc_id = item['name'].replace('/', '-').replace(' ', '_').replace('.', '')
                doc_ref = collection_ref.document(doc_id)
                batch.set(doc_ref, item, merge=True)
                
            batch.commit()
            print(f"  Uploaded {i + len(chunk)} / {len(items)} items...")
            
        print(f"Successfully uploaded all {cat_id} data to Firebase!")

if __name__ == "__main__":
    upload_all_data()
