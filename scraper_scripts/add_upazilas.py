import firebase_admin
from firebase_admin import credentials, firestore
import os

cred = credentials.Certificate(os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json'))
try:
    firebase_admin.initialize_app(cred)
except ValueError:
    pass

db = firestore.client()

upazilas = [
    "আগৈলঝাড়া উপজেলা",
    "বাকেরগঞ্জ উপজেলা",
    "বাবুগঞ্জ উপজেলা",
    "বানারিপাড়া উপজেলা",
    "গৌরনদী উপজেলা",
    "হিজলা উপজেলা",
    "বরিশাল সদর উপজেলা",
    "মেহেন্দিগঞ্জ উপজেলা",
    "মুলাদি উপজেলা",
    "উজিরপুর উপজেলা"
]

collection_ref = db.collection('categories').document('upazila').collection('upazilas')

for name in upazilas:
    existing = collection_ref.where('name', '==', name).get()
    if existing:
        print(f"Skipping {name}, already exists.")
    else:
        collection_ref.add({"name": name})
        print(f"Added {name}.")

print("All upazilas uploaded!")
