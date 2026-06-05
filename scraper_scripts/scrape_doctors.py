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

def get_specialties():
    url = "https://www.doctorbangladesh.com/doctors-barisal/"
    r = requests.get(url, headers={'User-Agent': 'Mozilla/5.0'})
    soup = BeautifulSoup(r.text, 'html.parser')
    
    links = []
    seen = set()
    for a in soup.find_all('a', href=True):
        if '-barisal/' in a['href'] and 'doctors-' not in a['href'] and 'hospitals-' not in a['href']:
            href = a['href']
            name = a.text.strip()
            if href not in seen and name:
                seen.add(href)
                links.append({"name": name, "url": href})
    return links

def scrape_doctor_profile_page(url, specialty_name):
    try:
        r = requests.get(url, headers={'User-Agent': 'Mozilla/5.0'})
        soup = BeautifulSoup(r.text, 'html.parser')
        
        name_tag = soup.find('h1')
        name = name_tag.text.strip() if name_tag else "Unknown Doctor"
        
        if name == "Unknown Doctor":
            return None
            
        qualifications = ""
        designation = ""
        chambers = []
        about = ""
        img_url = ""
        
        # Find the first image that is likely a doctor's photo
        for img in soup.find_all('img'):
            if 'src' in img.attrs and 'wp-content/uploads' in img['src']:
                src_lower = img['src'].lower()
                if 'logo' not in src_lower and 'male.png' not in src_lower and 'female.png' not in src_lower:
                    img_url = img['src']
                    break
                
        # The structure usually has h2 tags for "Chamber & Appointment"
        h2_tags = soup.find_all('h2')
        
        # We need to find the text before the first h2. This is usually qualifications and designation.
        content_after_h1 = []
        node = name_tag.find_next_sibling()
        while node and node.name != 'h2':
            # Could be p, div, ul, or span
            text = node.get_text(separator='\n').strip()
            # Split by lines in case it's a UL block or br tags
            lines = text.split('\n')
            for line in lines:
                line = line.strip()
                if line:
                    if 'MBBS' in line or 'FCPS' in line or 'MD' in line or 'MS' in line or 'DA' in line or 'BDS' in line or 'FRCS' in line or 'BCS' in line:
                        qualifications += line + "\n"
                    elif len(line) < 100 and ('Surgeon' in line or 'Specialist' in line or 'Consultant' in line or 'Professor' in line or 'Medical' in line or 'Hospital' in line or 'Owner' in line):
                        designation += line + "\n"
            node = node.find_next_sibling()
            
        # Parse Chambers
        for h2 in h2_tags:
            h2_text = h2.text.strip().lower()
            if 'chamber & appointment' in h2_text or 'chamber' in h2_text:
                chamber_node = h2.find_next_sibling()
                chamber_html = ""
                
                # We collect everything until the next h2 or h3 or hr
                while chamber_node and chamber_node.name not in ['h2', 'h3', 'hr']:
                    if chamber_node.name:
                        # Extract exact text pieces by splitting on <br> if it exists, or just use string
                        # Sometimes they use <br> for newline.
                        chamber_html += str(chamber_node)
                    chamber_node = chamber_node.find_next_sibling()
                
                if chamber_html:
                    c_soup = BeautifulSoup(chamber_html, 'html.parser')
                    
                    # Hospital name is usually strong, or just the first paragraph/line.
                    c_name = "Barisal Chamber"
                    c_address = ""
                    c_visiting = "Unknown"
                    c_phone = "Not Available"
                    
                    # Sometimes the name is in an anchor tag or strong tag
                    a_tag = c_soup.find('a')
                    strong_tag = c_soup.find('strong')
                    
                    if a_tag:
                        c_name = a_tag.text.strip()
                    elif strong_tag:
                        c_name = strong_tag.text.strip()
                        
                    # Extract address, visiting hours and appointment from text
                    lines = c_soup.get_text(separator='\n').split('\n')
                    for line in lines:
                        line = line.strip()
                        if not line:
                            continue
                            
                        # If we didn't find name yet, and this line is short and looks like a hospital name
                        if c_name == "Barisal Chamber" and ('Hospital' in line or 'Clinic' in line or 'Diagnostic' in line or 'Center' in line):
                            c_name = line
                            
                        if 'Address:' in line or 'Location:' in line:
                            c_address = line.replace('Address:', '').replace('Location:', '').strip()
                        elif 'Visiting Hour:' in line or 'Visiting hour:' in line:
                            c_visiting = line.replace('Visiting Hour:', '').replace('Visiting hour:', '').strip()
                        elif 'Appointment:' in line or 'Serial:' in line:
                            # Extract phone
                            phone_matches = re.findall(r'(?:\+88\s*)?01[3-9]\d{8}(?:,\s*(?:\+88\s*)?01[3-9]\d{8})*', line)
                            if phone_matches:
                                c_phone = phone_matches[0]
                            else:
                                c_phone = line.replace('Appointment:', '').replace('Serial:', '').strip()
                                
                        # fallback for lines without explicit prefixes
                        elif not c_address and len(line) > 15 and any(char.isdigit() for char in line) and ('Road' in line or 'Sadar' in line or 'Barisal' in line):
                             c_address = line
                        elif not c_phone and ('01' in line or '+88' in line):
                            phone_matches = re.findall(r'(?:\+88\s*)?01[3-9]\d{8}(?:,\s*(?:\+88\s*)?01[3-9]\d{8})*', line)
                            if phone_matches:
                                c_phone = phone_matches[0]
                                
                    chambers.append({
                        "name": c_name,
                        "address": c_address,
                        "visiting_hours": c_visiting,
                        "appointment_number": c_phone
                    })
            
            elif 'about dr' in h2_text or 'about' in h2_text:
                about_node = h2.find_next_sibling()
                while about_node and about_node.name not in ['h2', 'h3', 'hr']:
                    if about_node.name == 'p':
                        text = about_node.text.strip()
                        if 'Copyright' not in text and 'Doctor Bangladesh' not in text and 'Disclaimer' not in text:
                            about += text + "\n\n"
                    about_node = about_node.find_next_sibling()
        
        # If no explicit about h2 found, try to find a paragraph that starts with name
        if not about:
            paragraphs = soup.find_all('p')
            for p in paragraphs:
                text = p.text.strip()
                if len(text) > 60 and name in text and 'Copyright' not in text and 'Doctor Bangladesh' not in text:
                    about += text + "\n\n"
                    
        # Fallback for empty chambers
        if not chambers:
            chambers.append({
                "name": "Barisal Chamber",
                "address": "Barisal",
                "visiting_hours": "Unknown",
                "appointment_number": "Not Available"
            })
            
        if not about:
            about = f"{name} is a reputed doctor in Barisal."
            
        return {
            "name": name,
            "specialty": specialty_name,
            "qualifications": qualifications.strip(),
            "designation": designation.strip(),
            "chambers": chambers,
            "about": about.strip(),
            "image_url": img_url
        }
    except Exception as e:
        print(f"Error scraping {url}: {e}")
        return None

def scrape_all():
    specialties = get_specialties()
    
    doc_ref = db.collection('categories').document('doctor')
    doc_ref.set({
        "id": "doctor",
        "name": "ডাক্তার ও হাসপাতাল",
        "icon": "local_hospital",
        "color": "Colors.red",
        "specialties": [s['name'] for s in specialties]
    }, merge=True)
    
    items_ref = doc_ref.collection('items')
    
    # Delete existing items first to avoid duplicates when running again
    existing = items_ref.limit(500).get()
    for doc in existing:
        doc.reference.delete()
        
    # Attempt to delete more if there are over 500
    while True:
        existing = items_ref.limit(500).get()
        if not existing:
            break
        for doc in existing:
            doc.reference.delete()
    
    total_doctors = 0
    # Process all specialties
    # For testing, prioritize Anesthesiology and Cardiac Surgeon
    specialties = sorted(specialties, key=lambda x: 0 if 'Anesthesiology' in x['name'] or 'Cardiac Surgeon' in x['name'] else 1)
    
    for s in specialties:
        print(f"Scraping specialty: {s['name']}")
        try:
            r = requests.get(s['url'], headers={'User-Agent': 'Mozilla/5.0'})
            soup = BeautifulSoup(r.text, 'html.parser')
            
            # Find individual profile links
            profile_links = set()
            for a in soup.find_all('a', href=True):
                if '/dr-' in a['href'] or '/prof-dr-' in a['href'] or '/assoc-prof-dr-' in a['href']:
                    if 'doctorbangladesh.com' in a['href'] or a['href'].startswith('/'):
                        profile_links.add(a['href'] if a['href'].startswith('http') else 'https://www.doctorbangladesh.com' + a['href'])
            
            for link in profile_links:
                doc_data = scrape_doctor_profile_page(link, s['name'])
                if doc_data:
                    # Quick dedup logic inside loop
                    # check if already added in current run
                    items_ref.add(doc_data)
                    total_doctors += 1
                time.sleep(1) # Be nice to the server
                
            print(f"Added doctors for {s['name']}")
        except Exception as e:
            print(f"Failed to scrape {s['name']}: {e}")
        
    print(f"Successfully scraped and added {total_doctors} doctors!")

if __name__ == '__main__':
    scrape_all()
