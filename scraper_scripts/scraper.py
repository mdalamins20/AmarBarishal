import os
import requests
import io
import firebase_admin
from firebase_admin import credentials, firestore
from bs4 import BeautifulSoup
import pdfplumber

# SSL ওয়ার্নিং ইগনোর করার জন্য (অনেক সময় সরকারি সাইটে SSL ইস্যু থাকে)
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# ১. ফায়ারবেস ইনিশিয়ালাইজেশন
def initialize_firebase():
    # সার্ভিস একাউন্ট ফাইলের পাথ (আপনার ডাউনলোড করা JSON ফাইলের নাম দিন)
    cred_path = "serviceAccountKey.json"
    
    if not os.path.exists(cred_path):
        print(f"Error: '{cred_path}' পাওয়া যায়নি! দয়া করে ফায়ারবেস কনসোল থেকে JSON ফাইলটি ডাউনলোড করে এই ফোল্ডারে রাখুন।")
        return None
        
    try:
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
        db = firestore.client()
        print("ফায়ারবেস সফলভাবে কানেক্ট হয়েছে!")
        return db
    except ValueError:
        # যদি আগে থেকেই ইনিশিয়ালাইজ করা থাকে
        return firestore.client()
    except Exception as e:
        print(f"ফায়ারবেস কানেক্ট করতে সমস্যা: {e}")
        return None

# ২. ওয়েবসাইট থেকে পিডিএফ লিংক খুঁজে বের করা
def get_pdf_links(url):
    print(f"\nওয়েবসাইট স্ক্যান করা হচ্ছে: {url}")
    try:
        response = requests.get(url, verify=False) 
        soup = BeautifulSoup(response.content, 'html.parser')
        
        pdf_links = []
        # সব <a> ট্যাগ খুঁজছি
        for link in soup.find_all('a'):
            href = link.get('href')
            if href and href.endswith('.pdf'):
                # যদি রিলেটিভ লিংক হয়, তাহলে মূল ডোমেইনের সাথে যুক্ত করতে হবে
                if not href.startswith('http'):
                    base_url = "https://barisal.gov.bd" # মূল ডোমেইন
                    href = base_url + href
                pdf_links.append(href)
                
        return set(pdf_links) # ডুপ্লিকেট লিংক বাদ দেওয়ার জন্য set ব্যবহার করছি
    except Exception as e:
        print(f"লিংক পেতে সমস্যা হয়েছে: {e}")
        return []

# ৩. পিডিএফ থেকে ডাটা এক্সট্র্যাক্ট করা
def extract_data_from_pdf(pdf_url):
    print(f"পিডিএফ প্রসেস হচ্ছে: {pdf_url}")
    try:
        # পিডিএফ ফাইলটি রিকোয়েস্টের মাধ্যমে মেমোরিতে ডাউনলোড করছি
        response = requests.get(pdf_url, verify=False)
        pdf_file = io.BytesIO(response.content)
        
        extracted_data = []
        
        # pdfplumber দিয়ে পিডিএফ পড়া
        with pdfplumber.open(pdf_file) as pdf:
            for page in pdf.pages:
                # টেবিল এক্সট্র্যাক্ট করা (যদি পিডিএফে টেবিল থাকে)
                tables = page.extract_tables()
                for table in tables:
                    for row_idx, row in enumerate(table):
                        # সাধারণত টেবিলের প্রথম রো (0) হেডার বা টাইটেল হয়, চাইলে স্কিপ করতে পারেন
                        if row_idx == 0:
                            continue
                            
                        # খালি রো গুলো বাদ দিচ্ছি
                        if any(cell and str(cell).strip() for cell in row):
                            # ডাটাগুলোর কলাম অনুযায়ী ম্যাপিং (আপনার পিডিএফের স্ট্রাকচার অনুযায়ী এই ইনডেক্স পরিবর্তন করতে হবে)
                            # নিচের অংশটা একটি ডেমো - আসল পিডিএফের কলাম অনুযায়ী ঠিক করে নিতে হবে
                            institution_data = {
                                "name": str(row[1]).strip() if len(row) > 1 and row[1] else "Unknown",
                                "address": str(row[2]).strip() if len(row) > 2 and row[2] else "",
                                "type": "School/College", # ডিফল্ট টাইপ
                                "source_pdf": pdf_url
                            }
                            # যদি নাম empty না হয় তবেই লিস্টে এড করবো
                            if institution_data["name"] != "Unknown" and institution_data["name"] != "None":
                                extracted_data.append(institution_data)
                            
        return extracted_data
    except Exception as e:
        print(f"পিডিএফ পড়তে সমস্যা হয়েছে: {e}")
        return []

# ৪. ফায়ারবেসে ডাটা পুশ করা
def push_to_firestore(db, collection_name, data_list):
    if not data_list:
        print("পুশ করার মতো কোনো ডাটা নেই।")
        return
        
    collection_ref = db.collection(collection_name)
    count = 0
    for data in data_list:
        try:
            # ডাটা পুশ করা (Firestore নিজে থেকেই অটো-জেনারেল ID দিয়ে দিবে)
            collection_ref.add(data)
            count += 1
        except Exception as e:
            print(f"ডাটা সেভ করতে সমস্যা: {e}")
            
    print(f"\nসফলভাবে {count} টি ডাটা '{collection_name}' কালেকশনে পুশ করা হয়েছে!")

# মূল ফাংশন
def main():
    print("--- অটোমেটেড পিডিএফ স্ক্র্যাপার শুরু হচ্ছে ---")
    
    # ফায়ারবেস সেটআপ
    db = initialize_firebase()
    if not db:
        return
        
    # যে পেজে শিক্ষা প্রতিষ্ঠানের পিডিএফ তালিকা আছে এমন একটি লিংকের উদাহরণ
    # (সরকারি সাইটের প্রকৃত ইউআরএল বসাতে হবে)
    target_url = "https://barisal.gov.bd/site/view/education_institute" 
    
    # ১. পিডিএফ লিংক সংগ্রহ
    pdf_links = list(get_pdf_links(target_url))
    print(f"মোট {len(pdf_links)} টি পিডিএফ লিংক পাওয়া গেছে।")
    
    all_data = []
    
    # ২. প্রতিটি পিডিএফ থেকে ডাটা এক্সট্র্যাক্ট
    # (আপাতত টেস্টিং এর জন্য শুধু প্রথম ১-২ টা পিডিএফ চেক করার জন্য pdf_links[:1] ব্যবহার করতে পারেন)
    for link in pdf_links:
        data = extract_data_from_pdf(link)
        all_data.extend(data)
        
    # ৩. ডাটা ফায়ারবেসে সেভ
    if all_data:
        print(f"\nমোট {len(all_data)} টি প্রতিষ্ঠানের ডাটা পাওয়া গেছে। ফায়ারবেসে সেভ করা হচ্ছে...")
        push_to_firestore(db, "educational_institutions", all_data)
    else:
        print("\nকোনো ডাটা পাওয়া যায়নি। পিডিএফের ভেতরের স্ট্রাকচার চেক করুন।")

if __name__ == "__main__":
    main()
