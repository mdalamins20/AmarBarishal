import os
import requests

logos = {
    'prothom_alo': 'https://paloimages.prothom-alo.com/contents/themes/public/assets/images/apple-touch-icon.png',
    'jugantor': 'https://www.jugantor.com/assets/frontend/images/logo.png',
    'jagonews24': 'https://cdn.jagonews24.com/media/common/logo.png',
    'daily_star': 'https://cdn.thedailystar.net/sites/default/files/thedailystar_social_share.png',
    'kaler_kantho': 'https://www.kalerkantho.com/frontend/images/logo.png',
    'naya_diganta': 'https://www.dailynayadiganta.com/resources/images/Naya-Diganta-logo.png',
    'barishal_news': 'https://barishalnews.com/wp-content/uploads/2021/05/Barishal-News-Logo.png',
    'barishal_times': 'https://www.barishaltimes.com/wp-content/uploads/2021/04/Barishal-Times-Logo.png',
    'barishal_crime_news': 'https://barishalcrimenews.com/wp-content/uploads/2022/02/bc-logo.png'
}

os.makedirs('../assets/images/logos', exist_ok=True)

headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.9',
}

for name, url in logos.items():
    try:
        r = requests.get(url, headers=headers, timeout=10)
        if r.status_code == 200:
            ext = 'png'
            with open(f'../assets/images/logos/{name}.{ext}', 'wb') as f:
                f.write(r.content)
            print(f"Downloaded {name}")
        else:
            print(f"Failed {name} with status {r.status_code}")
    except Exception as e:
        print(f"Failed {name} with error {e}")
