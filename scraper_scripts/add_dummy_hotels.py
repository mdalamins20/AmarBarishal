import firebase_admin
from firebase_admin import credentials, firestore
import os

try:
    cred = credentials.Certificate(os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json'))
    firebase_admin.initialize_app(cred)
except ValueError:
    pass
    
db = firestore.client()

hotels = [
    {
        "name": "হোটেল গ্র্যান্ড পার্ক",
        "type": "hotel",
        "address": "বঙ্গবন্ধু উদ্যান সংলগ্ন, বরিশাল সদর",
        "price_per_night": "৳৩,৫০০",
        "rating": 4.8,
        "reviews": 124,
        "image_url": "https://images.unsplash.com/photo-1566073771259-6a8506099945?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
        "mobile": "017XXXXXXXX",
        "amenities": ["Wi-Fi", "AC", "Restaurant", "Swimming Pool", "Parking"],
        "description": "বরিশালের প্রাণকেন্দ্রে অবস্থিত একটি বিলাসবহুল ফোর স্টার মানের হোটেল। এখানে সুইমিং পুল, আধুনিক জিম এবং রুফটপ রেস্টুরেন্ট রয়েছে।"
    },
    {
        "name": "এরিনা হোটেল ও রিসোর্ট",
        "type": "hotel",
        "address": "সদর রোড, বরিশাল",
        "price_per_night": "৳২,২০০",
        "rating": 4.5,
        "reviews": 89,
        "image_url": "https://images.unsplash.com/photo-1551882547-ff40c0d139af?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
        "mobile": "018XXXXXXXX",
        "amenities": ["Wi-Fi", "AC", "Breakfast", "Room Service"],
        "description": "পারিবারিক বা ব্যবসায়িক ট্যুরের জন্য একটি চমৎকার ও সাশ্রয়ী থাকার জায়গা। সদর রোডের কাছে হওয়ায় যাতায়াত অত্যন্ত সহজ।"
    },
    {
        "name": "হোটেল এথেনা ইন্টারন্যাশনাল",
        "type": "hotel",
        "address": "চৌমাথা, বরিশাল সদর",
        "price_per_night": "৳১,৫০০",
        "rating": 4.2,
        "reviews": 56,
        "image_url": "https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
        "mobile": "019XXXXXXXX",
        "amenities": ["Wi-Fi", "AC", "Restaurant", "Conference Room"],
        "description": "সব ধরণের আধুনিক সুযোগ-সুবিধা সম্বলিত একটি সুপরিচিত হোটেল। ব্যবসায়িক মিটিং বা কনফারেন্সের জন্য এখানে বড় হলরুম রয়েছে।"
    },
    {
        "name": "বরিশাল ইন",
        "type": "hotel",
        "address": "নথুল্লাবাদ বাসস্ট্যান্ড, বরিশাল",
        "price_per_night": "৳৮০০",
        "rating": 3.9,
        "reviews": 210,
        "image_url": "https://images.unsplash.com/photo-1505691938895-1758d7feb511?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
        "mobile": "016XXXXXXXX",
        "amenities": ["Non-AC", "Fan", "24/7 Service"],
        "description": "স্বল্প খরচে ভালো মানের থাকার জন্য এটি একটি উপযুক্ত জায়গা। বাসস্ট্যান্ডের একেবারে কাছে হওয়ায় ভ্রমণকারীদের জন্য এটি বেশ সুবিধাজনক।"
    }
]

collection_ref = db.collection('categories').doc('hotel').collection('items')

for hotel in hotels:
    collection_ref.add(hotel)
    
print("Successfully added 4 dummy hotels to Firestore!")
