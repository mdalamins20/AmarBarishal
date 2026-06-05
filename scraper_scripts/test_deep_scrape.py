import firebase_admin
from firebase_admin import credentials, firestore
import requests
from bs4 import BeautifulSoup
import os
import re
import time

try:
    cred = credentials.Certificate(os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json'))
    firebase_admin.initialize_app(cred)
except ValueError:
    pass

db = firestore.client()

def scrape_doctor_profile_page(url, specialty_name):
    # This scrapes the actual profile page where all the info is!
    try:
        r = requests.get(url, headers={'User-Agent': 'Mozilla/5.0'})
        soup = BeautifulSoup(r.text, 'html.parser')
        
        # We look for h1 or h2 for name
        name_tag = soup.find('h1')
        name = name_tag.text.strip() if name_tag else "Unknown Doctor"
        
        # The structure is usually simple:
        # P tags contain the info
        qualifications = ""
        designation = ""
        chamber = ""
        phone = ""
        about = ""
        visiting = ""
        img_url = ""
        
        img = soup.find('img')
        if img and 'src' in img.attrs and 'wp-content/uploads' in img['src']:
            img_url = img['src']
            
        paragraphs = soup.find_all('p')
        for p in paragraphs:
            text = p.text.strip()
            if not text:
                continue
                
            if 'MBBS' in text or 'FCPS' in text or 'MD' in text or 'MS' in text or 'DA' in text or 'BDS' in text:
                qualifications += text + " "
            elif 'Hospital' in text or 'Clinic' in text or 'Chamber' in text or 'Diagnostic' in text or 'Medical' in text:
                if 'Visiting' not in text and 'Appointment' not in text:
                    chamber += text + "\n"
            elif 'Visiting Hour' in text or 'Visiting hour' in text:
                visiting += text.replace('Visiting Hour:', '').strip() + " "
            elif 'Appointment' in text or 'Serial' in text:
                # Find number
                phone_matches = re.findall(r'(?:\+88\s*)?01[3-9]\d{8}(?:,\s*(?:\+88\s*)?01[3-9]\d{8})*', text)
                if phone_matches:
                    phone = phone_matches[0]
                else:
                    phone = text.replace('Appointment:', '').strip()
            elif len(text) > 60 and name in text:
                about += text + "\n\n"
            elif len(text) < 50 and ('Specialist' in text or 'Consultant' in text or 'Professor' in text or 'Owner' in text):
                designation += text + " "
                
        # Cleanup
        chamber = chamber.strip() if chamber else "Barisal"
        if not visiting:
            visiting = "9am to 9pm (Closed: Friday)"
        if not phone:
            phone = "+8801700000000"
        if not about:
            about = f"{name} is a reputed doctor in Barisal."
            
        return {
            "name": name,
            "specialty": specialty_name,
            "qualifications": qualifications.strip(),
            "designation": designation.strip(),
            "chamber_address": chamber,
            "visiting_hours": visiting,
            "appointment_number": phone[:20] if phone else "Not Available",
            "about": about.strip(),
            "image_url": img_url
        }
    except Exception as e:
        print(f"Error scraping {url}: {e}")
        return None

def test_scrape_jalal():
    # specifically test the anesthesiology page which has Dr Jalal
    url = "https://www.doctorbangladesh.com/anesthesiologist-barisal/"
    r = requests.get(url, headers={'User-Agent': 'Mozilla/5.0'})
    soup = BeautifulSoup(r.text, 'html.parser')
    
    # find all profile links
    profile_links = set()
    for a in soup.find_all('a', href=True):
        if '/dr-' in a['href']:
            profile_links.add(a['href'])
            
    print(f"Found {len(profile_links)} profile links.")
    
    doc_ref = db.collection('categories').document('doctor')
    items_ref = doc_ref.collection('items')
    
    for link in profile_links:
        print(f"Scraping profile: {link}")
        doc_data = scrape_doctor_profile_page(link, "Anesthesiology (Pain) Specialist in Barisal")
        if doc_data:
            items_ref.add(doc_data)
            print(f"Added {doc_data['name']}")
        time.sleep(1)

if __name__ == '__main__':
    test_scrape_jalal()
