import firebase_admin
from firebase_admin import credentials, firestore
import os

def upload_manual_ambulances():
    try:
        cred = credentials.Certificate(os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json'))
        firebase_admin.initialize_app(cred)
    except ValueError:
        pass
        
    db = firestore.client()
    collection_ref = db.collection('categories').document('ambulance').collection('items')
    
    # 1. Delete existing data
    print("Deleting old ambulance data...")
    docs = collection_ref.stream()
    deleted_count = 0
    for doc in docs:
        doc.reference.delete()
        deleted_count += 1
    print(f"Deleted {deleted_count} old records.")
    
    # 2. Add new data
    ambulances = [
        {
            "name": "National Emergency Hotline (Police, Fire, and Ambulance)",
            "type": "এম্বুলেন্স",
            "mobile": "999",
            "address": "Anywhere"
        },
        {
            "name": "Sher-e-Bangla Medical College Hospital",
            "type": "এম্বুলেন্স",
            "mobile": "01782755500",
            "address": "Barisal"
        },
        {
            "name": "Barisal General Hospital",
            "type": "এম্বুলেন্স",
            "mobile": "01735923757",
            "mobile2": "01701248189",
            "address": "Barisal"
        },
        {
            "name": "Fire Brigade & Civil Defence (Barisal Sadar)",
            "type": "এম্বুলেন্স",
            "mobile": "0431-65222",
            "mobile2": "01878001111",
            "mobile3": "01983886677",
            "address": "Barisal Sadar"
        },
        {
            "name": "Babuganj Upazila Health Complex",
            "type": "এম্বুলেন্স",
            "mobile": "01724049028",
            "address": "Babuganj"
        }
    ]
    
    print("Uploading new data...")
    for item in ambulances:
        collection_ref.add(item)
        print(f"Added: {item['name']}")
        
    print("Done!")

if __name__ == "__main__":
    upload_manual_ambulances()
