import os
import requests
import io
import firebase_admin
from firebase_admin import credentials, firestore
from bs4 import BeautifulSoup
import pdfplumber

import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

def initialize_firebase():
    cred_path = "serviceAccountKey.json"
    
    if not os.path.exists(cred_path):
        print(f"Error: '{cred_path}' পাওয়া যায়নি!")
        return None
        
    try:
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
        db = firestore.client()
        print("ফায়ারবেস সফলভাবে কানেক্ট হয়েছে!")
        return db
    except ValueError:
        return firestore.client()
    except Exception as e:
        print(f"ফায়ারবেস কানেক্ট করতে সমস্যা: {e}")
        return None

def get_pdf_links(url):
    print(f"\nওয়েবসাইট স্ক্যান করা হচ্ছে: {url}")
    try:
        response = requests.get(url, verify=False) 
        soup = BeautifulSoup(response.content, 'html.parser')
        
        pdf_links = []
        for link in soup.find_all('a'):
            href = link.get('href')
            if href and href.endswith('.pdf'):
                if not href.startswith('http'):
                    base_url = "https://barisal.gov.bd"
                    href = base_url + href
                pdf_links.append(href)
                
        return set(pdf_links)
    except Exception as e:
        print(f"লিংক পেতে সমস্যা হয়েছে: {e}")
        return []

def extract_data_from_pdf(pdf_url):
    print(f"পিডিএফ প্রসেস হচ্ছে: {pdf_url}")
    try:
        response = requests.get(pdf_url, verify=False)
        pdf_file = io.BytesIO(response.content)
        
        extracted_data = []
        
        with pdfplumber.open(pdf_file) as pdf:
            for page in pdf.pages:
                tables = page.extract_tables()
                for table in tables:
                    for row_idx, row in enumerate(table):
                        if row_idx == 0:
                            continue
                            
                        if any(cell and str(cell).strip() for cell in row):
                            # কলাম ইনডেক্স ঠিক করে দিচ্ছি: ১=নাম, ২=প্রধান শিক্ষক, ৩=মোবাইল
                            name = str(row[1]).strip() if len(row) > 1 and row[1] else "Unknown"
                            headmaster = str(row[2]).strip() if len(row) > 2 and row[2] else "তথ্য নেই"
                            mobile = str(row[3]).strip() if len(row) > 3 and row[3] else ""
                            
                            institution_data = {
                                "name": name,
                                "headmaster": headmaster,
                                "mobile": mobile,
                                "type": "School/College",
                                "source_pdf": pdf_url
                            }
                            if name != "Unknown" and name != "None" and name != "":
                                extracted_data.append(institution_data)
                            
        return extracted_data
    except Exception as e:
        print(f"পিডিএফ পড়তে সমস্যা হয়েছে: {e}")
        return []

def push_to_firestore(db, data_list):
    if not data_list:
        print("পুশ করার মতো কোনো ডাটা নেই।")
        return
        
    # Flutter অ্যাপ অনুযায়ী ক্যাটাগরি কালেকশনের পাথ
    collection_ref = db.collection('categories').doc('schoolCollege').collection('items')
    count = 0
    for data in data_list:
        try:
            collection_ref.add(data)
            count += 1
        except Exception as e:
            print(f"ডাটা সেভ করতে সমস্যা: {e}")
            
    print(f"\nসফলভাবে {count} টি ডাটা 'School/College' ক্যাটাগরিতে পুশ করা হয়েছে!")

def main():
    print("--- অটোমেটেড পিডিএফ স্ক্র্যাপার শুরু হচ্ছে ---")
    
    db = initialize_firebase()
    if not db:
        return
        
    target_url = "https://barisal.gov.bd/pages/static-pages/697876a9c4774958d7c4389b" 
    
    pdf_links = list(get_pdf_links(target_url))
    print(f"মোট {len(pdf_links)} টি পিডিএফ লিংক পাওয়া গেছে।")
    
    all_data = []
    
    for link in pdf_links:
        data = extract_data_from_pdf(link)
        all_data.extend(data)
        
    if all_data:
        print(f"\nমোট {len(all_data)} টি প্রতিষ্ঠানের ডাটা পাওয়া গেছে। ফায়ারবেসে সেভ করা হচ্ছে...")
        push_to_firestore(db, all_data)
    else:
        print("\nকোনো ডাটা পাওয়া যায়নি। পিডিএফের ভেতরের স্ট্রাকচার চেক করুন।")

if __name__ == "__main__":
    main()
