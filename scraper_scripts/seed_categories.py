import os
import firebase_admin
from firebase_admin import credentials, firestore

def seed_categories():
    cred_path = "serviceAccountKey.json"
    if not os.path.exists(cred_path):
        print("Error: serviceAccountKey.json পাওয়া যায়নি!")
        return

    try:
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
        db = firestore.client()
        
        # ডিফল্ট ক্যাটাগরির লিস্ট
        categories = [
            {"id": "schoolCollege", "name": "School/College", "icon": "education", "color": "#00A8E8", "order": 1},
            {"id": "hospital", "name": "হাসপাতাল", "icon": "hospital", "color": "#FF5252", "order": 2},
            {"id": "police", "name": "পুলিশ ও থানা", "icon": "police", "color": "#448AFF", "order": 3},
            {"id": "ambulance", "name": "অ্যাম্বুলেন্স", "icon": "ambulance", "color": "#FF1744", "order": 4},
            {"id": "fire_service", "name": "ফায়ার সার্ভিস", "icon": "fire_service", "color": "#FF6D00", "order": 5},
            {"id": "news", "name": "পত্রিকা", "icon": "news", "color": "#00BFA5", "order": 6},
            {"id": "upazila", "name": "উপজেলা পরিচিতি", "icon": "landscape", "color": "#8E24AA", "order": 7},
            {"id": "doctor", "name": "ডাক্তার", "icon": "doctor", "color": "#00897B", "order": 8},
            {"id": "hotel", "name": "হোটেল ও আবাসন", "icon": "hotel", "color": "#FDD835", "order": 9},
        ]

        print("ফায়ারবেসে ক্যাটাগরিগুলো আপলোড করা হচ্ছে...")
        for cat in categories:
            doc_id = cat.pop('id')
            db.collection('categories').doc(doc_id).set(cat)
            print(f"✅ সফলভাবে যোগ করা হয়েছে: {cat['name']}")

        print("\nসবগুলো ক্যাটাগরি সফলভাবে ডাটাবেসে যোগ করা হয়েছে! এবার আপনার অ্যাপটি চেক করুন।")

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    seed_categories()
