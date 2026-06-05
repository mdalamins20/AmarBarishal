from fastapi import FastAPI, Query
from fastapi.middleware.cors import CORSMiddleware
import requests
import io
from bs4 import BeautifulSoup
import xml.etree.ElementTree as ET
import pdfplumber
import urllib3
import json
import time
import unicodeconverter as uc
import re
from datetime import datetime, timedelta
import urllib.parse
import xml.etree.ElementTree as ET
import concurrent.futures
import firebase_admin
from firebase_admin import credentials, firestore

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

CACHE = {}
CACHE_TTL = 3600  # 1 hour cache

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize Firebase for scraping
try:
    if not firebase_admin._apps:
        cred = credentials.Certificate('serviceAccountKey.json')
        firebase_admin.initialize_app(cred)
except Exception as e:
    print(e)

def translate_english_to_bengali(text):
    if not text:
        return text
    
    en_digits = "0123456789"
    bn_digits = "০১২৩৪৫৬৭৮৯"
    trans = str.maketrans(en_digits, bn_digits)
    text = text.translate(trans)
    
    dictionary = {
        "govt.": "সরকারি",
        "govt": "সরকারি",
        "government": "সরকারি",
        "college": "কলেজ",
        "school": "স্কুল",
        "high": "হাই",
        "secondary": "মাধ্যমিক",
        "primary": "প্রাথমিক",
        "women's": "মহিলা",
        "womens": "মহিলা",
        "women": "মহিলা",
        "girls": "বালিকা",
        "boys": "বালক",
        "degree": "ডিগ্রী",
        "university": "বিশ্ববিদ্যালয়",
        "barishal": "বরিশাল",
        "sadar": "সদর",
        "model": "মডেল",
        "academy": "একাডেমি",
        "institute": "ইন্সটিটিউট",
        "and": "অ্যান্ড",
        "science": "সায়েন্স",
        "medical": "মেডিকেল"
    }
    
    for eng, ben in dictionary.items():
        text = re.sub(rf'\b{re.escape(eng)}\b', ben, text, flags=re.IGNORECASE)
        
    return text.strip()

import base64

def get_pdf_links(url):
    try:
        response = requests.get(url, verify=False) 
        soup = BeautifulSoup(response.content, 'html.parser')
        
        pdf_links = []
        
        def extract_links(html_soup):
            for link in html_soup.find_all('a'):
                href = link.get('href')
                if href and href.lower().endswith('.pdf'):
                    if not href.startswith('http'):
                        base_url = "https://barisal.gov.bd"
                        href = base_url + href
                    pdf_links.append(href)
                    
        extract_links(soup)
        
        for rt in soup.find_all('rt-renderer'):
            encoded = rt.get('encoded-content')
            if encoded:
                try:
                    decoded = base64.b64decode(encoded).decode('utf-8')
                    soup2 = BeautifulSoup(decoded, 'html.parser')
                    extract_links(soup2)
                except:
                    pass
                    
        return set(pdf_links)
    except Exception as e:
        print(f"লিংক পেতে সমস্যা: {e}")
        return []

def extract_data_from_html_table(url):
    try:
        response = requests.get(url, verify=False)
        soup = BeautifulSoup(response.content, 'html.parser')
        
        extracted_data = []
        tables = soup.find_all('table')
        
        for rt in soup.find_all('rt-renderer'):
            encoded = rt.get('encoded-content')
            if encoded:
                try:
                    decoded = base64.b64decode(encoded).decode('utf-8')
                    soup2 = BeautifulSoup(decoded, 'html.parser')
                    tables.extend(soup2.find_all('table'))
                except:
                    pass
        
        for table in tables:
            rows = table.find_all('tr')
            for row_idx, row in enumerate(rows):
                if row_idx == 0:
                    continue  # Skip header
                
                cells = [c.get_text(separator=" ", strip=True) for c in row.find_all(['td', 'th'])]
                if not cells or len(cells) < 2:
                    continue
                    
                raw_name = cells[1]
                raw_address = ""
                raw_headmaster = ""
                raw_mobile = ""
                
                mobile_idx = -1
                for i in range(2, len(cells)):
                    digits = re.sub(r'[^\d০-৯]', '', cells[i])
                    if len(digits) >= 10:
                        mobile_idx = i
                        raw_mobile = cells[i]
                        break
                        
                if mobile_idx == 5:
                    raw_address = cells[2]
                    raw_headmaster = cells[3]
                elif mobile_idx == 4:
                    designations = ["শিক্ষক", "প্রধান", "সুপার", "অধ্যক্ষ", "সহকারী", "মৌলভি", "teacher", "head", "principal", "পদবী"]
                    address_keywords = ["ডাকঘর", "গ্রাম", "ইউনিয়ন", "ওয়ার্ড", "উপজেলা", "জেলা", "সড়ক", "রোড", "road", "village"]
                    
                    c3_lower = cells[3].lower()
                    c2_lower = cells[2].lower()
                    
                    if any(d in c3_lower for d in designations) and not any(a in c2_lower for a in address_keywords):
                        raw_address = ""
                        raw_headmaster = cells[2]
                    else:
                        raw_address = cells[2]
                        raw_headmaster = cells[3]
                elif mobile_idx == 3:
                    raw_address = ""
                    raw_headmaster = cells[2]
                else:
                    if len(cells) >= 6:
                        raw_address = cells[2]
                        raw_headmaster = cells[3]
                        raw_mobile = cells[5]
                    elif len(cells) == 5:
                        raw_address = cells[2]
                        raw_headmaster = cells[3]
                        raw_mobile = cells[4]
                    elif len(cells) == 4:
                        raw_address = cells[2]
                        raw_mobile = cells[3]
                
                name = uc.convert_bijoy_to_unicode(raw_name) if raw_name != "Unknown" else raw_name
                name = translate_english_to_bengali(name)
                
                address = uc.convert_bijoy_to_unicode(raw_address) if raw_address else ""
                address = translate_english_to_bengali(address)
                
                headmaster = uc.convert_bijoy_to_unicode(raw_headmaster) if raw_headmaster != "তথ্য নেই" else raw_headmaster
                headmaster = translate_english_to_bengali(headmaster)
                
                mobile = uc.convert_bijoy_to_unicode(raw_mobile) if raw_mobile else ""
                mobile = translate_english_to_bengali(mobile)
                
                if name and name != "Unknown":
                    inst_type = "হাই স্কুল" 
                    lower_name = name.lower()
                    if "মাদ্রাসা" in lower_name or "ফাজিল" in lower_name or "কামিল" in lower_name or "দাখিল" in lower_name or "আলিম" in lower_name:
                        inst_type = "মাদ্রাসা"
                    elif "কলেজ" in lower_name or "মহাবিদ্যালয়" in lower_name:
                        inst_type = "কলেজ"
                    elif "প্রাথমিক" in lower_name or "primary" in lower_name:
                        inst_type = "প্রাথমিক স্কুল"
                    elif "মাধ্যমিক" in lower_name or "উচ্চ" in lower_name or "high" in lower_name:
                        inst_type = "হাই স্কুল"
                        
                    extracted_data.append({
                        "name": name,
                        "address": address,
                        "headmaster": headmaster,
                        "mobile": mobile,
                        "type": inst_type,
                        "source": url
                    })
                        
        return extracted_data
    except Exception as e:
        print(f"এইচটিএমএল টেবিল পড়তে সমস্যা: {e}")
        return []

def extract_hospital_data(url):
    try:
        response = requests.get(url, verify=False)
        soup = BeautifulSoup(response.content, 'html.parser')
        
        extracted_data = []
        tables = soup.find_all('table')
        
        for rt in soup.find_all('rt-renderer'):
            encoded = rt.get('encoded-content')
            if encoded:
                try:
                    decoded = base64.b64decode(encoded).decode('utf-8')
                    soup2 = BeautifulSoup(decoded, 'html.parser')
                    tables.extend(soup2.find_all('table'))
                except:
                    pass
        
        for table in tables:
            rows = table.find_all('tr')
            for row_idx, row in enumerate(rows):
                if row_idx == 0:
                    continue  # Skip header
                
                cells = [c.get_text(separator=" ", strip=True) for c in row.find_all(['td', 'th'])]
                if not cells or len(cells) < 4:
                    continue
                
                detected_mobile_idx = -1
                for i in range(1, len(cells)):
                    digits = re.sub(r'[^\d০-৯]', '', cells[i])
                    if len(digits) >= 10:
                        detected_mobile_idx = i
                        break
                        
                if detected_mobile_idx != -1:
                    raw_mobile = cells[detected_mobile_idx]
                    raw_designation = cells[detected_mobile_idx - 1] if detected_mobile_idx > 0 else ""
                    raw_provider = cells[detected_mobile_idx - 2] if detected_mobile_idx > 1 else ""
                    raw_name = cells[detected_mobile_idx - 3] if detected_mobile_idx > 2 else cells[0]
                else:
                    if len(cells) == 5:
                        raw_name = cells[1]
                        raw_provider = cells[2]
                        raw_designation = cells[3]
                        raw_mobile = cells[4]
                    else:
                        raw_name = cells[0]
                        raw_provider = cells[1]
                        raw_designation = cells[2]
                        raw_mobile = cells[3]
                
                name = uc.convert_bijoy_to_unicode(raw_name) if raw_name else ""
                name = translate_english_to_bengali(name)
                
                provider = uc.convert_bijoy_to_unicode(raw_provider) if raw_provider else ""
                provider = translate_english_to_bengali(provider)
                
                designation = uc.convert_bijoy_to_unicode(raw_designation) if raw_designation else ""
                designation = translate_english_to_bengali(designation)
                
                mobile = uc.convert_bijoy_to_unicode(raw_mobile) if raw_mobile else ""
                mobile = translate_english_to_bengali(mobile)
                
                if name and name != "Unknown":
                    extracted_data.append({
                        "name": name,
                        "provider_name": provider,
                        "provider_designation": designation,
                        "mobile": mobile,
                        "type": "হাসপাতাল",
                        "source": url
                    })
                        
        return extracted_data
    except Exception as e:
        print(f"Hospital HTML error: {e}")
        return []

def extract_data_from_pdf(pdf_url):
    try:
        response = requests.get(pdf_url, verify=False)
        pdf_file = io.BytesIO(response.content)
        
        extracted_data = []
        
        with pdfplumber.open(pdf_file) as pdf:
            for page in pdf.pages:
                tables = page.extract_tables()
                for table in tables:
                    for row_idx, row in enumerate(table):
                        if row_idx == 0 or not row:
                            continue
                            
                        if any(cell and str(cell).strip() for cell in row):
                            cells = [str(c).replace('\n', ' ').strip() if c else "" for c in row]
                            
                            raw_name = cells[1] if len(cells) > 1 else "Unknown"
                            raw_address = ""
                            raw_headmaster = ""
                            raw_mobile = ""
                            
                            mobile_idx = -1
                            for i in range(2, len(cells)):
                                digits = re.sub(r'[^\d০-৯]', '', cells[i])
                                if len(digits) >= 10:
                                    mobile_idx = i
                                    raw_mobile = cells[i]
                                    break
                                    
                            if mobile_idx == 5:
                                raw_address = cells[2]
                                raw_headmaster = cells[3]
                            elif mobile_idx == 4:
                                designations = ["শিক্ষক", "প্রধান", "সুপার", "অধ্যক্ষ", "সহকারী", "মৌলভি", "teacher", "head", "principal", "পদবী"]
                                address_keywords = ["ডাকঘর", "গ্রাম", "ইউনিয়ন", "ওয়ার্ড", "উপজেলা", "জেলা", "সড়ক", "রোড", "road", "village"]
                                
                                c3_lower = cells[3].lower()
                                c2_lower = cells[2].lower()
                                
                                if any(d in c3_lower for d in designations) and not any(a in c2_lower for a in address_keywords):
                                    raw_address = ""
                                    raw_headmaster = cells[2]
                                else:
                                    raw_address = cells[2]
                                    raw_headmaster = cells[3]
                            elif mobile_idx == 3:
                                raw_address = ""
                                raw_headmaster = cells[2]
                            else:
                                if len(cells) >= 6:
                                    raw_address = cells[2]
                                    raw_headmaster = cells[3]
                                    raw_mobile = cells[5]
                                elif len(cells) == 5:
                                    raw_headmaster = cells[2]
                                    raw_mobile = cells[4]
                                elif len(cells) == 4:
                                    raw_headmaster = cells[2]
                                    raw_mobile = cells[3]
                            
                            name = uc.convert_bijoy_to_unicode(raw_name) if raw_name != "Unknown" else raw_name
                            name = translate_english_to_bengali(name)
                            
                            address = uc.convert_bijoy_to_unicode(raw_address) if raw_address else ""
                            address = translate_english_to_bengali(address)
                            
                            headmaster = uc.convert_bijoy_to_unicode(raw_headmaster) if raw_headmaster != "তথ্য নেই" else raw_headmaster
                            headmaster = translate_english_to_bengali(headmaster)
                            
                            mobile = uc.convert_bijoy_to_unicode(raw_mobile) if raw_mobile else ""
                            mobile = translate_english_to_bengali(mobile)
                            
                            inst_type = "হাই স্কুল" 
                            lower_name = name.lower()
                            if "মাদ্রাসা" in lower_name or "ফাজিল" in lower_name or "কামিল" in lower_name or "দাখিল" in lower_name or "আলিম" in lower_name:
                                inst_type = "মাদ্রাসা"
                            elif "কলেজ" in lower_name or "মহাবিদ্যালয়" in lower_name:
                                inst_type = "কলেজ"
                            elif "প্রাথমিক" in lower_name or "primary" in lower_name:
                                inst_type = "প্রাথমিক স্কুল"
                            elif "মাধ্যমিক" in lower_name or "উচ্চ" in lower_name or "high" in lower_name:
                                inst_type = "হাই স্কুল"
                                
                            institution_data = {
                                "name": name,
                                "address": address,
                                "headmaster": headmaster,
                                "mobile": mobile,
                                "type": inst_type,
                                "source_pdf": pdf_url
                            }
                            if name != "Unknown" and name != "None" and name != "":
                                extracted_data.append(institution_data)
                            
        return extracted_data
    except Exception as e:
        print(f"পিডিএফ পড়তে সমস্যা: {e}")
        return []

@app.get("/api/categories")
def get_categories():
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
    return {"status": "success", "data": categories}

@app.get("/test")
async def test_endpoint():
    return {"message": "FastAPI is running!"}

@app.get("/debug_ambu")
async def debug_ambu():
    url = "https://roktospondon.com/ambulance"
    headers = {'User-Agent': 'Mozilla/5.0'}
    response = requests.get(url, headers=headers, verify=False, timeout=20)
    return {"html": response.text}

@app.get("/api/categories/{category_id}/items")
def get_category_items(category_id: str):
    current_time = time.time()
    if category_id in CACHE:
        cache_entry = CACHE[category_id]
        if current_time - cache_entry['timestamp'] < CACHE_TTL:
            return {"status": "success", "data": cache_entry['data']}

@app.get("/scrape-diagnostics")
def scrape_diagnostics():
    try:
        if not firebase_admin._apps:
            import os
            key_path = os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json')
            cred = credentials.Certificate(key_path)
            firebase_admin.initialize_app(cred)
            
        url = "https://www.findoutdoctor.com/2016/08/best-hospital-clinic-in-barisal.html"
        response = requests.get(url)
        soup = BeautifulSoup(response.content, 'html.parser')
        post_body = soup.find(id='post-body')
        if not post_body:
            return {"success": False, "msg": "No post-body"}
        
        divs = post_body.find_all('div', style=re.compile(r'text-align:\s*center', re.I))
        entries = []
        current_entry = []
        for div in divs:
            text = div.get_text(strip=True)
            if not text and current_entry:
                entries.append(current_entry)
                current_entry = []
            elif text:
                current_entry.append(text)
        if current_entry:
            entries.append(current_entry)

        parsed_data = []
        for entry in entries:
            if len(entry) >= 3:
                name = entry[0].replace(u'\xa0', u' ')
                address = entry[1].replace(u'\xa0', u' ')
                phone_str = ' '.join(entry[2:]).replace(u'\xa0', u' ')
                phones = re.findall(r'[\d\-+]+', phone_str)
                valid_phones = [p for p in phones if len(p.replace('-', '')) >= 6]
                unique_phones = []
                for p in valid_phones:
                    if p not in unique_phones:
                        unique_phones.append(p)
                if 'Tel:' in phone_str or 'Phone:' in phone_str or 'Hotline' in phone_str or unique_phones:
                    parsed_data.append({
                        'name': name,
                        'address': address,
                        'phone1': unique_phones[0] if len(unique_phones) > 0 else '',
                        'phone2': unique_phones[1] if len(unique_phones) > 1 else ''
                    })
        
        db = firestore.client()
        batch = db.batch()
        col_ref = db.collection('categories').document('diagnostic').collection('items')
        
        # delete existing
        docs = col_ref.get()
        for doc in docs:
            batch.delete(doc.reference)
            
        for data in parsed_data:
            doc_ref = col_ref.document()
            batch.set(doc_ref, data)
            
        batch.commit()
        return {"success": True, "count": len(parsed_data), "data": parsed_data[:2]}
    except Exception as e:
        import traceback
        return {"success": False, "error": str(e), "trace": traceback.format_exc()}
            
    if category_id == "schoolCollege":
        target_urls = [
            "https://barisal.gov.bd/pages/static-pages/697876a9c4774958d7c4389b",
            "https://barisal.gov.bd/pages/static-pages/697895a035ce18e1c066a84c",
            "https://barisal.gov.bd/pages/static-pages/6978958a35ce18e1c066a06b",
            "https://barisal.gov.bd/pages/static-pages/697876a7c4774958d7c4377f"
        ]
        
        html_data = []
        pdf_links = []
        
        for url in target_urls:
            html_data.extend(extract_data_from_html_table(url))
            pdf_links.extend(list(get_pdf_links(url)))
            
        pdf_data = []
        for pdf_url in pdf_links:
            pdf_data.extend(extract_data_from_pdf(pdf_url))
            
        merged_dict = {}
        for item in html_data:
            key = item['name'].replace('\n', ' ').strip()
            merged_dict[key] = item
            
        for item in pdf_data:
            key = item['name'].replace('\n', ' ').strip()
            if key in merged_dict:
                merged_dict[key].update(item)
            else:
                merged_dict[key] = item
                
        all_data = list(merged_dict.values())
        
        CACHE[category_id] = {
            'timestamp': current_time,
            'data': all_data
        }
        
        return {"status": "success", "data": all_data}
    elif category_id == "hospital":
        url = "https://barishal.gov.bd/pages/static-pages/69789b9135ce18e1c066f1c8"
        data = extract_hospital_data(url)
        CACHE[category_id] = {
            'timestamp': current_time,
            'data': data
        }
        return {"status": "success", "data": data}
    else:
        return {"status": "success", "data": []}

@app.get("/api/news")
def get_news(date: str = Query(None), source_id: str = Query(None)):
    news_items = []
    real_ua = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    
    source_map = {
        "prothom_alo": {"type": "gnews", "domain": "prothomalo.com", "name": "প্রথম আলো"},
        "jugantor": {"type": "gnews", "domain": "jugantor.com", "name": "যুগান্তর"},
        "jagonews24": {"type": "gnews", "domain": "jagonews24.com", "name": "জাগো নিউজ ২৪"},
        "daily_star": {"type": "gnews", "domain": "thedailystar.net", "name": "ডেইলি স্টার"},
        "kaler_kantho": {"type": "gnews", "domain": "kalerkantho.com", "name": "কালের কণ্ঠ"},
        "naya_diganta": {"type": "gnews", "domain": "dailynayadiganta.com", "name": "নয়া দিগন্ত"},
        "barishal_news": {"type": "wp", "url": "https://barishalnews.com/", "name": "বরিশাল নিউজ"},
        "barishal_times": {"type": "wp", "url": "https://www.barishaltimes.com/", "name": "বরিশাল টাইমস"},
        "barishal_crime_news": {"type": "wp", "url": "https://barishalcrimenews.com/", "name": "বরিশাল ক্রাইম নিউজ"},
    }
    
    def decode_gnews_url(url):
        import base64
        import re
        if 'news.google.com/rss/articles/' in url:
            token = url.split('articles/')[-1].split('?')[0]
            try:
                padding = '=' * (4 - len(token) % 4)
                decoded = base64.urlsafe_b64decode(token + padding).decode('utf-8', errors='ignore')
                match = re.search(r'(https?://[^\s\x00-\x1f\x7f"\'<>]+)', decoded)
                if match:
                    return match.group(1)
            except:
                pass
        return url

    def fetch_full_news(link):
        try:
            final_url = decode_gnews_url(link)
            cookies = {'CONSENT': 'YES+cb.20210720-07-p0.en+FX+410'}
            page_req = requests.get(final_url, headers={'User-Agent': real_ua}, cookies=cookies, timeout=10)
            page_soup = BeautifulSoup(page_req.content, 'html.parser')
            
            # If still a Google News redirect (fallback if decode fails)
            if 'news.google.com' in final_url:
                noscript = page_soup.find('noscript')
                if noscript:
                    meta = noscript.find('meta')
                    if meta and 'url=' in meta.get('content', '').lower():
                        content_str = meta.get('content')
                        match = re.search(r'url=(.*)', content_str, re.IGNORECASE)
                        if match:
                            final_url = match.group(1).strip()
                elif page_soup.find('a', jsname=True) or page_soup.find('a', class_=lambda c: c and 'Wwrzyd' in c):
                    a_tag = page_soup.find('a', jsname=True) or page_soup.find('a')
                    if a_tag and a_tag.get('href') and a_tag.get('href').startswith('http'):
                        final_url = a_tag.get('href')
                elif page_soup.find('a'):
                    # Sometimes the consent page has an a tag to the actual article
                    a_tags = page_soup.find_all('a')
                    for a in a_tags:
                        href = a.get('href', '')
                        if href.startswith('http') and 'google.com' not in href:
                            final_url = href
                            break

                # Fetch actual article if a new URL was found
                if final_url != link and 'news.google.com' not in final_url:
                    try:
                        page_req = requests.get(final_url, headers={'User-Agent': real_ua}, cookies=cookies, timeout=10)
                        page_soup = BeautifulSoup(page_req.content, 'html.parser')
                    except:
                        pass

            og_image = page_soup.find('meta', property='og:image')
            img = og_image.get('content') if og_image else ""
            
            # Better text extraction
            content_div = page_soup.find('div', class_=lambda c: c and ('content' in c.lower() or 'details' in c.lower() or 'article' in c.lower()))
            
            # List of promotional phrases to exclude
            promo_phrases = [
                "গুগল নিউজ চ্যানেল ফলো করুন",
                "গুগল নিউজে ফলো করুন",
                "Google News",
                "আরও পড়ুন",
                "আরও পড়ুন",
                "বিস্তারিত পড়ুন",
                "বিস্তারিত পড়ুন",
                "সব খবর পেতে",
                "ইউটিউব চ্যানেল সাবস্ক্রাইব করুন",
                "ফেসবুক পেজ"
            ]
            
            filtered_paragraphs = []
            if content_div:
                for tag in content_div(['script', 'style', 'img', 'iframe', 'nav', 'header', 'footer', 'ul', 'ol']):
                    tag.decompose()
                raw_text = content_div.get_text(separator='\n\n').strip()
                lines = raw_text.split('\n')
            else:
                p_tags = page_soup.find_all('p')
                lines = [p.text.strip() for p in p_tags]
                
            for line in lines:
                text = line.strip()
                if len(text) < 40:
                    continue
                is_promo = False
                for promo in promo_phrases:
                    if promo in text:
                        is_promo = True
                        break
                if not is_promo:
                    filtered_paragraphs.append(text)
                    
            full_text = '\n\n'.join(filtered_paragraphs)
                
            if not full_text or len(full_text) < 100:
                full_text = "বিস্তারিত খবর পড়তে লিংকে ক্লিক করুন বা ওয়েবসাইট ভিজিট করুন।"
                
            # Fallback for image from page if og:image fails
            if not img:
                img_tag = page_soup.find('img')
                if img_tag and img_tag.get('src') and img_tag.get('src').startswith('http'):
                    img = img_tag.get('src')
                    
            return img, full_text, final_url
        except Exception as e:
            print("Fetch Error:", e)
            return "", "বিস্তারিত খবর পড়তে লিংকে ক্লিক করুন বা ওয়েবসাইট ভিজিট করুন。", link

    # 1. Google News Aggregation (Premium Sources)
    def fetch_gnews_item(item):
        title = item.findtext('title')
        link = item.findtext('link')
        pubDate = item.findtext('pubDate')
        source_name = item.findtext('source') or "সংবাদমাধ্যম"
        
        # Clean title by removing the source name if it's appended at the end
        if " - " in title:
            title = " - ".join(title.split(" - ")[:-1])
            
        img, full_text, final_link = fetch_full_news(link)
        
        return {
            "name": title,
            "url": final_link,
            "date": pubDate,
            "image_url": img,
            "excerpt": "বিস্তারিত জানতে লিংকে ক্লিক করুন।",
            "full_news": full_text if len(full_text) > 50 else "এই খবরটি অ্যাপের ভিতরে পড়ার সুবিধা নেই। দয়া করে সম্পূর্ণ খবর পড়তে লিংকে ক্লিক করুন।",
            "source": source_name
        }

    # Determine which sources to scrape
    run_gnews = True
    gnews_domain = None
    run_wp = []
    
    if source_id and source_id in source_map:
        source_info = source_map[source_id]
        if source_info["type"] == "gnews":
            run_gnews = True
            gnews_domain = source_info["domain"]
            run_wp = []
        elif source_info["type"] == "wp":
            run_gnews = False
            run_wp = [source_info]
    else:
        # Default all behavior
        run_gnews = True
        run_wp = [source_map["barishal_news"], source_map["barishal_times"], source_map["barishal_crime_news"]] if not date else []

    if run_gnews:
        try:
            # Using Bing News RSS because Google News obfuscates links
            query = "বরিশাল"
            if gnews_domain:
                query = f"site:{gnews_domain}"
                
            # Bing doesn't support complex date filtering easily in RSS, so we fetch and filter locally if needed
            # We encode the query
            encoded_query = urllib.parse.quote(query)
            url = f"https://www.bing.com/news/search?q={encoded_query}&format=rss"
            
            r = requests.get(url, headers={'User-Agent': real_ua}, timeout=10)
            root = ET.fromstring(r.content)
            items = root.findall('.//item')[:20] # Top 20 from Bing News
            
            def fetch_bing_item(item):
                title = item.findtext('title')
                link = item.findtext('link')
                pubDate = item.findtext('pubDate')
                
                # Bing RSS links have the real URL in the 'url' parameter of their click tracker
                # e.g. http://www.bing.com/news/apiclick.aspx?...&url=https%3a%2f%2fwww.prothomalo.com...
                final_link = link
                if 'url=' in link:
                    match = re.search(r'url=([^&]+)', link)
                    if match:
                        final_link = urllib.parse.unquote(match.group(1))
                        
                source_name = "সংবাদমাধ্যম"
                # Extract source from Bing's custom namespace
                for child in item:
                    if child.tag.endswith('Source'):
                        source_name = child.text
                        break
                
                img, full_text, final_link = fetch_full_news(final_link)
                
                # Fallback to Bing's provided image if extraction failed
                if not img:
                    for child in item:
                        if child.tag.endswith('Image'):
                            img = child.text
                            break
                            
                return {
                    "name": title,
                    "url": final_link,
                    "date": pubDate,
                    "image_url": img,
                    "excerpt": "বিস্তারিত জানতে লিংকে ক্লিক করুন।",
                    "full_news": full_text if len(full_text) > 50 else "এই খবরটি অ্যাপের ভিতরে পড়ার সুবিধা নেই। দয়া করে সম্পূর্ণ খবর পড়তে লিংকে ক্লিক করুন।",
                    "source": source_name
                }
                
            with concurrent.futures.ThreadPoolExecutor(max_workers=5) as executor:
                bing_results = list(executor.map(fetch_bing_item, items))
                
            for item in bing_results:
                if item: news_items.append(item)
        except Exception as e:
            print("Error fetching Bing News:", e)

    # 2. Existing Local WordPress Scraping
    if run_wp:
        def scrape_wp_site(base_url, source_name):
            try:
                url = base_url
                if date:
                    parts = date.split('-')
                    if len(parts) == 3:
                        url = f"{base_url.rstrip('/')}/{parts[0]}/{parts[1]}/{parts[2]}/"
                r = requests.get(url, headers={'User-Agent': real_ua}, timeout=10)
                if r.status_code != 200: return
                soup = BeautifulSoup(r.content, 'html.parser')
                articles = soup.find_all('article')
                if not articles:
                    articles = soup.find_all('div', class_=lambda c: c and ('post' in c or 'news-item' in c))
                count = 0
                for article in articles:
                    title_tag = article.find(['h1', 'h2', 'h3'])
                    a_tag = title_tag.find('a') if title_tag else article.find('a')
                    if not a_tag: continue
                    title = a_tag.text.strip()
                    link = a_tag.get('href')
                    if not title or not link or not link.startswith('http'): continue
                    if any(item['url'] == link for item in news_items): continue
                    img_tag = article.find('img')
                    img = img_tag.get('src') if img_tag else ""
                    p_tag = article.find('p')
                    excerpt = p_tag.text.strip() if p_tag else "বিস্তারিত জানতে লিংকে ক্লিক করুন।"
                    og_img, full_text, final_link = fetch_full_news(link)
                    if not img: img = og_img
                    news_items.append({"name": title, "url": final_link, "date": date if date else str(datetime.now().date()), "image_url": img, "excerpt": excerpt, "full_news": full_text, "source": source_name})
                    count += 1
                    if count >= 10: break # Max 10 from specific local site
            except Exception as e:
                print(f"Error {source_name}:", e)

        for wp_source in run_wp:
            scrape_wp_site(wp_source["url"], wp_source["name"])

    return {"status": "success", "data": news_items}

@app.get("/api/test_gnews")
def test_gnews(date: str = Query(None)):
    import urllib.parse
    import xml.etree.ElementTree as ET
    
    real_ua = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    query = "বরিশাল"
    if date:
        # e.g., date = "2026-06-02", we search after:2026-06-01 before:2026-06-03
        parts = date.split('-')
        if len(parts) == 3:
            day = int(parts[2])
            month = int(parts[1])
            year = int(parts[0])
            # Simplified date logic for testing
            after_date = f"{year}-{month:02d}-{day-1:02d}"
            before_date = f"{year}-{month:02d}-{day+1:02d}"
            q = f"{query} after:{after_date} before:{before_date}"
        else:
            q = query
    else:
        q = query
        
    encoded_query = urllib.parse.quote(q)
    url = f"https://news.google.com/rss/search?q={encoded_query}&hl=bn&gl=BD&ceid=BD:bn"
    
    try:
        r = requests.get(url, headers={'User-Agent': 'Mozilla/5.0'}, timeout=10)
        root = ET.fromstring(r.content)
        items = root.findall('.//item')
        
        results = []
        for item in items[:2]:
            link = item.findtext('link')
            
            # test fetching og:image
            img_url = "None"
            try:
                page_req = requests.get(link, headers={'User-Agent': real_ua}, timeout=10)
                page_soup = BeautifulSoup(page_req.content, 'html.parser')
                og = page_soup.find('meta', property='og:image')
                if og:
                    img_url = og.get('content')
                else:
                    # try to find a redirect URL
                    noscript = page_soup.find('noscript')
                    if noscript:
                        meta = noscript.find('meta')
                        if meta and 'url=' in meta.get('content', ''):
                            new_url = meta.get('content').split('url=')[-1]
                            new_req = requests.get(new_url, headers={'User-Agent': real_ua}, timeout=10)
                            new_soup = BeautifulSoup(new_req.content, 'html.parser')
                            og2 = new_soup.find('meta', property='og:image')
                            if og2: img_url = og2.get('content')
            except Exception as ex:
                img_url = str(ex)
                
            results.append({
                "title": item.findtext('title'),
                "link": link,
                "img": img_url,
                "source": item.findtext('source')
            })
        return {"status": "success", "url": url, "count": len(items), "data": results}
    except Exception as e:
        return {"status": "error", "message": str(e)}

@app.get("/api/debug_gnews_redirect")
def debug_gnews_redirect():
    url = "https://barishalnews.com/wp-json/wp/v2/posts?per_page=1"
    r = requests.get(url, headers={'User-Agent': 'Mozilla/5.0'})
    return {"status": r.status_code, "text": r.text[:1000]}

@app.get("/api/test_docs")
def test_docs():
    import requests
    from bs4 import BeautifulSoup
    url = "https://www.doctorbangladesh.com/doctors-barisal/"
    r = requests.get(url, headers={'User-Agent': 'Mozilla/5.0'})
    soup = BeautifulSoup(r.text, 'html.parser')
    
    links = []
    for a in soup.find_all('a', href=True):
        if '-barisal/' in a['href'] and 'doctors-' not in a['href'] and 'hospitals-' not in a['href']:
            links.append((a.text.strip(), a['href']))
            
    # get distinct
    distinct_links = []
    seen = set()
    for name, href in links:
        if href not in seen and name:
            seen.add(href)
            distinct_links.append({"name": name, "url": href})
            
    return distinct_links

@app.get("/api/test_docs2")
def test_docs2():
    import requests
    url = "https://www.doctorbangladesh.com/anesthesiologist-barisal/"
    r = requests.get(url, headers={'User-Agent': 'Mozilla/5.0'})
    return {"html": r.text}

@app.get("/api/scrape_docs_now")
def scrape_docs_now():
    import subprocess
    import sys
    try:
        subprocess.Popen([sys.executable, "scraper_scripts/scrape_doctors.py"])
        return {"status": "started", "message": "Scraping started in the background."}
    except Exception as e:
        return {"error": str(e)}

@app.get("/api/test_scrape_jalal")
def api_test_scrape_jalal():
    import subprocess
    import sys
    try:
        result = subprocess.run([sys.executable, "scraper_scripts/copy_image.py"], capture_output=True, text=True)
        return {"stdout": result.stdout, "stderr": result.stderr}
    except Exception as e:
        return {"error": str(e)}

@app.get("/api/dedup_doctors")
def api_dedup_doctors():
    import subprocess
    import sys
    try:
        result = subprocess.run([sys.executable, "scraper_scripts/dedup_doctors.py"], capture_output=True, text=True)
        return {"stdout": result.stdout, "stderr": result.stderr}
    except Exception as e:
        return {"error": str(e)}

@app.get("/api/check_docs_now")
def check_docs_now():
    import firebase_admin
    from firebase_admin import credentials, firestore
    import os
    try:
        try:
            cred = credentials.Certificate(os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json'))
            firebase_admin.initialize_app(cred)
        except ValueError:
            pass
        db = firestore.client()
        items = db.collection('categories').document('doctor').collection('items').get()
        return {"total_doctors": len(items)}
    except Exception as e:
        return {"error": str(e)}

@app.get("/api/check_hotel_data")
def check_hotel_data():
    import firebase_admin
    from firebase_admin import credentials, firestore
    import os
    try:
        cred = credentials.Certificate(os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json'))
        firebase_admin.initialize_app(cred)
    except ValueError:
        pass
    db = firestore.client()
    
    docs = db.collection('categories').document('hotel').collection('items').get()
    return {"hotels": [d.to_dict() for d in docs]}
    
@app.get("/api/test_vromon_html")
def test_vromon_html():
    import requests
    from bs4 import BeautifulSoup
    url = "https://vromonguide.com/best-hotels-in-barishal"
    r = requests.get(url, headers={'User-Agent': 'Mozilla/5.0'})
    soup = BeautifulSoup(r.content, 'html.parser')

    hotels = []
    headings = soup.find_all(['h2', 'h3'])
    for heading in headings:
        text = heading.get_text(strip=True)
        if not text or ("বরিশাল" not in text and "হোটেল" not in text):
            continue
            
        sibling = heading.find_next_sibling()
        html_snippets = []
        
        while sibling and sibling.name not in ['h2', 'h3']:
            html_snippets.append(str(sibling)[:150]) # Capture first 150 chars to debug
            sibling = sibling.find_next_sibling()
            
        hotels.append({'name': text, 'snippets': html_snippets})
            
    return {"hotels": hotels}
    
@app.get("/api/scrape_wiki_upazila")
def scrape_wiki_upazila():
    name = "বাবুগঞ্জ উপজেলা"
    url = "https://bn.wikipedia.org/wiki/%E0%A6%AC%E0%A6%BE%E0%A6%AC%E0%A7%81%E0%A6%97%E0%A6%9E%E0%A7%8D%E0%A6%9C_%E0%A6%89%E0%A6%AA%E0%A6%9C%E0%A7%87%E0%A6%B2%E0%A6%BE"
    import firebase_admin
    from firebase_admin import credentials, firestore
    import os
    import re
    import requests
    from bs4 import BeautifulSoup
    
    try:
        cred = credentials.Certificate(os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json'))
        firebase_admin.initialize_app(cred)
    except ValueError:
        pass
        
    db = firestore.client()
    
    r = requests.get(url, headers={'User-Agent': 'Mozilla/5.0'})
    soup = BeautifulSoup(r.content, 'html.parser')
    
    content = soup.find('div', {'id': 'mw-content-text'})
    
    sections = {}
    current_section = "ভূমিকা"
    sections[current_section] = []
    
    if content:
        parser_output = content.find('div', class_='mw-parser-output')
        if parser_output:
            for element in parser_output.find_all(['h2', 'h3', 'p', 'ul', 'ol']):
                if element.name in ['h2', 'h3']:
                    heading = element.get_text(strip=True).replace('[সম্পাদনা]', '').replace('[edit]', '')
                    current_section = heading
                    sections[current_section] = []
                elif element.name in ['p', 'ul', 'ol'] and current_section:
                    text = element.get_text(separator=' ', strip=True)
                    if text:
                        # Remove citations like [1], [ ১ ], [ক] etc.
                        text = re.sub(r'\[\s*[0-9a-zA-Zঅ-হ০-৯]+\s*\]', '', text)
                        # Clean up extra spaces
                        text = re.sub(r'\s+', ' ', text).strip()
                        sections[current_section].append(text)
                        
    final_data = {}
    for k, v in sections.items():
        if v:
            final_data[k] = "\n\n".join(v)
            
    img_url = ""
    infobox = soup.find('table', class_=lambda c: c and 'infobox' in c.lower())
    if infobox:
        img = infobox.find('img')
        if img:
            img_url = img['src']
            if img_url.startswith('//'):
                img_url = "https:" + img_url
            
    final_data['image_url'] = img_url
    
    collection_ref = db.collection('categories').document('upazila').collection('upazilas')
    existing = collection_ref.where('name', '==', name).get()
    
    if existing:
        doc_id = existing[0].id
        collection_ref.document(doc_id).set({"wiki_data": final_data}, merge=True)
    else:
        collection_ref.add({"name": name, "wiki_data": final_data})
        
    return {"status": "success", "name": name, "sections": list(final_data.keys()), "image_url": img_url}

@app.get("/api/scrape_banglapedia")
def scrape_banglapedia():
    name = "বাবুগঞ্জ উপজেলা"
    url = "https://bn.banglapedia.org/index.php/%E0%A6%AC%E0%A6%BE%E0%A6%AC%E0%A7%81%E0%A6%97%E0%A6%9E%E0%A7%8D%E0%A6%9C_%E0%A6%89%E0%A6%AA%E0%A6%9C%E0%A7%87%E0%A6%B2%E0%A6%BE"
    import firebase_admin
    from firebase_admin import credentials, firestore
    import os
    import requests
    from bs4 import BeautifulSoup
    import re
    
    try:
        cred = credentials.Certificate(os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json'))
        firebase_admin.initialize_app(cred)
    except ValueError:
        pass

    db = firestore.client()
    
    r = requests.get(url, headers={'User-Agent': 'Mozilla/5.0'})
    soup = BeautifulSoup(r.content, 'html.parser')
    
    content = soup.find('div', {'id': 'mw-content-text'})
    
    banglapedia_data = {}
    
    if content:
        parser_output = content.find('div', class_='mw-parser-output')
        if parser_output:
            for p in parser_output.find_all('p'):
                if not p.get_text(strip=True):
                    continue
                
                full_text = p.get_text(separator=' ', strip=True)
                full_text = re.sub(r'\[\s*[0-9a-zA-Zঅ-হ০-৯]+\s*\]', '', full_text)
                full_text = re.sub(r'\s+', ' ', full_text).strip()
                
                first_element = None
                for child in p.children:
                    if child.name:
                        first_element = child
                        break
                    elif str(child).strip():
                        break
                        
                title = "অন্যান্য তথ্য"
                if first_element and first_element.name in ['i', 'b']:
                    possible_title = first_element.get_text(strip=True)
                    if full_text.startswith(possible_title):
                        title = possible_title
                        full_text = full_text[len(title):].strip()
                        if full_text.startswith(':'):
                            full_text = full_text[1:].strip()
                            
                if title == "বাবুগঞ্জ উপজেলা" or title == name:
                    title = "ভূমিকা"
                elif title == "তথ্যসূত্র":
                    continue
                    
                if title in banglapedia_data:
                    banglapedia_data[title] += "\n\n" + full_text
                else:
                    banglapedia_data[title] = full_text
    
    if not banglapedia_data:
        return {"status": "error", "message": "No content found in Banglapedia page."}
    
    collection_ref = db.collection('categories').document('upazila').collection('upazilas')
    existing = collection_ref.where('name', '==', name).get()
    
    if existing:
        doc_id = existing[0].id
        doc_ref = collection_ref.document(doc_id)
        
        doc_data = existing[0].to_dict()
        wiki_data = doc_data.get("wiki_data", {})
        
        # Remove old wrong keys
        old_keys = ["বাংলাপিডিয়া থেকে প্রাপ্ত তথ্য", f"{name.replace(' উপজেলা', '')} এর অন্যান্য তথ্য"]
        for k in old_keys:
            if k in wiki_data:
                del wiki_data[k]
                
        # Merge Banglapedia data
        for title, text in banglapedia_data.items():
            if title in wiki_data:
                # If section already exists, append
                if "[বাংলাপিডিয়া]" not in wiki_data[title]:
                    wiki_data[title] += f"\n\n[বাংলাপিডিয়া থেকে]:\n{text}"
            else:
                wiki_data[title] = text
                
        doc_ref.update({
            "wiki_data": wiki_data
        })
        return {"status": "success", "name": name, "doc_id": doc_id, "updated": True}
    else:
        return {"status": "error", "message": "Upazila not found in database to attach Banglapedia info"}

@app.get("/api/reset_babuganj")
def reset_babuganj():
    import firebase_admin
    from firebase_admin import credentials, firestore
    import os
    
    try:
        cred = credentials.Certificate(os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json'))
        firebase_admin.initialize_app(cred)
    except ValueError:
        pass
        
    db = firestore.client()
    collection_ref = db.collection('categories').document('upazila').collection('upazilas')
    existing = collection_ref.where('name', '==', 'বাবুগঞ্জ উপজেলা').get()
    
    if existing:
        doc_id = existing[0].id
        doc_ref = collection_ref.document(doc_id)
        doc_ref.update({
            "wiki_data": firestore.DELETE_FIELD
        })
        return {"status": "success", "message": "Deleted wiki_data from Babuganj."}
    return {"status": "error"}

@app.get("/api/scrape_all_upazilas")
def scrape_all_upazilas():
    import firebase_admin
    from firebase_admin import credentials, firestore
    import os
    import requests
    from bs4 import BeautifulSoup
    import re
    
    try:
        cred = credentials.Certificate(os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json'))
        firebase_admin.initialize_app(cred)
    except ValueError:
        pass
    
    db = firestore.client()
    
    upazilas = {
        "আগৈলঝাড়া উপজেলা": "https://bn.wikipedia.org/wiki/%E0%A6%86%E0%A6%97%E0%A7%88%E0%A6%B2%E0%A6%9D%E0%A6%BE%E0%A6%A1%E0%A6%BC%E0%A6%BE_%E0%A6%89%E0%A6%AA%E0%A6%9C%E0%A7%87%E0%A6%B2%E0%A6%BE",
        "বাকেরগঞ্জ উপজেলা": "https://bn.wikipedia.org/wiki/%E0%A6%AC%E0%A6%BE%E0%A6%95%E0%A7%87%E0%A6%B0%E0%A6%97%E0%A6%9E%E0%A7%8D%E0%A6%9C_%E0%A6%89%E0%A6%AA%E0%A6%9C%E0%A7%87%E0%A6%B2%E0%A6%BE",
        "বাবুগঞ্জ উপজেলা": "https://bn.wikipedia.org/wiki/%E0%A6%AC%E0%A6%BE%E0%A6%AC%E0%A7%81%E0%A6%97%E0%A6%9E%E0%A7%8D%E0%A6%9C_%E0%A6%89%E0%A6%AA%E0%A6%9C%E0%A7%87%E0%A6%B2%E0%A6%BE",
        "বানারিপাড়া উপজেলা": "https://bn.wikipedia.org/wiki/%E0%A6%AC%E0%A6%BE%E0%A6%A8%E0%A6%BE%E0%A6%B0%E0%A7%80%E0%A6%AA%E0%A6%BE%E0%A6%A1%E0%A6%BC%E0%A6%BE_%E0%A6%89%E0%A6%AA%E0%A6%9C%E0%A7%87%E0%A6%B2%E0%A6%BE",
        "গৌরনদী উপজেলা": "https://bn.wikipedia.org/wiki/%E0%A6%97%E0%A7%8C%E0%A6%B0%E0%A6%A8%E0%A6%A6%E0%A7%80_%E0%A6%89%E0%A6%AA%E0%A6%9C%E0%A7%87%E0%A6%B2%E0%A6%BE",
        "হিজলা উপজেলা": "https://bn.wikipedia.org/wiki/%E0%A6%B9%E0%A6%BF%E0%A6%9C%E0%A6%B2%E0%A6%BE_%E0%A6%89%E0%A6%AA%E0%A6%9C%E0%A7%87%E0%A6%B2%E0%A6%BE",
        "বরিশাল সদর উপজেলা": "https://bn.wikipedia.org/wiki/%E0%A6%AC%E0%A6%B0%E0%A6%BF%E0%A6%B6%E0%A6%BE%E0%A6%B2_%E0%A6%B8%E0%A6%A6%E0%A6%B0_%E0%A6%89%E0%A6%AA%E0%A6%9C%E0%A7%87%E0%A6%B2%E0%A6%BE",
        "মেহেন্দিগঞ্জ উপজেলা": "https://bn.wikipedia.org/wiki/%E0%A6%AE%E0%A7%87%E0%A6%B9%E0%A7%87%E0%A6%A8%E0%A7%8D%E0%A6%A6%E0%A6%BF%E0%A6%97%E0%A6%9E%E0%A7%8D%E0%A6%9C_%E0%A6%89%E0%A6%AA%E0%A6%9C%E0%A7%87%E0%A6%B2%E0%A6%BE",
        "মুলাদি উপজেলা": "https://bn.wikipedia.org/wiki/%E0%A6%AE%E0%A7%81%E0%A6%B2%E0%A6%BE%E0%A6%A6%E0%A7%80_%E0%A6%89%E0%A6%AA%E0%A6%9C%E0%A7%87%E0%A6%B2%E0%A6%BE",
        "উজিরপুর উপজেলা": "https://bn.wikipedia.org/wiki/%E0%A6%89%E0%A6%9C%E0%A6%BF%E0%A6%B0%E0%A6%AA%E0%A7%81%E0%A6%B0_%E0%A6%89%E0%A6%AA%E0%A6%9C%E0%A7%87%E0%A6%B2%E0%A6%BE"
    }
    
    results = []
    
    for name, url in upazilas.items():
        r = requests.get(url, headers={'User-Agent': 'Mozilla/5.0'})
        if r.status_code != 200:
            results.append({"name": name, "status": "fetch_failed"})
            continue
            
        soup = BeautifulSoup(r.content, 'html.parser')
        content = soup.find('div', {'id': 'mw-content-text'})
        
        sections = {}
        current_section = None
        img_url = ""
        
        infobox = soup.find('table', class_='infobox')
        if infobox:
            img_tag = infobox.find('img')
            if img_tag and img_tag.has_attr('src'):
                img_url = "https:" + img_tag['src']
                img_url = img_url.replace('/thumb', '')
                if img_url.count('/') > 0:
                    img_url = '/'.join(img_url.split('/')[:-1])

        if content:
            parser_output = content.find('div', class_='mw-parser-output')
            if parser_output:
                intro_texts = []
                for child in parser_output.children:
                    if child.name in ['h2', 'h3']:
                        break
                    elif child.name == 'div' and child.has_attr('class') and any('heading' in str(c) for c in child['class']):
                        break
                        
                    if child.name == 'p':
                        text = child.get_text(separator=' ', strip=True)
                        if text:
                            text = re.sub(r'\[\s*[0-9a-zA-Zঅ-হ০-৯]+\s*\]', '', text)
                            text = re.sub(r'\s+', ' ', text).strip()
                            intro_texts.append(text)
                            
                if intro_texts:
                    sections["ভূমিকা"] = "\n\n".join(intro_texts)

                for element in parser_output.children:
                    heading = None
                    if element.name in ['h2', 'h3']:
                        heading = element.get_text(strip=True).replace('[সম্পাদনা]', '')
                    elif element.name == 'div' and element.has_attr('class') and any('heading' in str(c) for c in element['class']):
                        h_tag = element.find(['h2', 'h3'])
                        if h_tag:
                            heading = h_tag.get_text(strip=True).replace('[সম্পাদনা]', '')
                            
                    if heading:
                        if heading in ['আরও দেখুন', 'তথ্যসূত্র', 'বহিঃসংযোগ']:
                            current_section = None
                            continue
                        current_section = heading
                        sections[current_section] = []
                    elif element.name in ['p', 'ul', 'ol'] and current_section:
                        text = element.get_text(separator=' ', strip=True)
                        if text:
                            text = re.sub(r'\[\s*[0-9a-zA-Zঅ-হ০-৯]+\s*\]', '', text)
                            text = re.sub(r'\s+', ' ', text).strip()
                            sections[current_section].append(text)
                            
        final_data = {}
        for k, v in sections.items():
            if isinstance(v, list):
                joined = "\n\n".join(v)
                if joined.strip():
                    final_data[k] = joined
            else:
                if v.strip():
                    final_data[k] = v

        if img_url:
            final_data['image_url'] = img_url
            
        collection_ref = db.collection('categories').document('upazila').collection('upazilas')
        existing = collection_ref.where('name', '==', name).get()
        
        if existing:
            doc_id = existing[0].id
            doc_ref = collection_ref.document(doc_id)
            doc_ref.set({"wiki_data": final_data}, merge=True)
            results.append({"name": name, "status": "success", "sections_found": list(final_data.keys())})
        else:
            results.append({"name": name, "status": "not_found_in_db"})
            
    return {"status": "completed", "results": results}

@app.get("/api/test_wiki")
def test_wiki():
    import requests
    from bs4 import BeautifulSoup
    
    url = "https://bn.wikipedia.org/wiki/%E0%A6%AC%E0%A6%BE%E0%A6%AC%E0%A7%81%E0%A6%97%E0%A6%9E%E0%A7%8D%E0%A6%9C_%E0%A6%89%E0%A6%AA%E0%A6%9C%E0%A7%87%E0%A6%B2%E0%A6%BE"
    r = requests.get(url, headers={'User-Agent': 'Mozilla/5.0'})
    soup = BeautifulSoup(r.content, 'html.parser')
    parser_output = soup.find('div', class_='mw-parser-output')
    
    html = str(parser_output)[:1000] if parser_output else "None"
    return {"html": html}

@app.get("/api/seed_hotels")
def seed_hotels():
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
        
    return {"status": "success", "count": len(hotels)}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
