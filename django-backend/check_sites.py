from api.db_utils import fetch_all

sites = fetch_all('SELECT area, street, site_name, customer_name, created_at FROM sites ORDER BY created_at DESC LIMIT 5')
print('Recent sites:')
for s in sites:
    print(f"  {s['area']} / {s['street']} / {s['customer_name']} {s['site_name']} - {s['created_at']}")

areas = fetch_all("SELECT DISTINCT area FROM sites WHERE area != '' ORDER BY area")
print(f'\nTotal areas: {len(areas)}')
for a in areas:
    print(f"  - {a['area']}")
