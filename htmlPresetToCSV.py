from bs4 import BeautifulSoup
import csv

PRESET_FILENAME='' # Filename of the HTML preset file.
MOD_DESTINATION='' # Destination folder for the mods.
CSV_HEADERS = ['mod_id', 'destination', 'description'] # CSV headers.

with open(PRESET_FILENAME, 'r') as presetFile:
    contents = presetFile.read()
    soup = BeautifulSoup(contents, 'html.parser')

    columns = {}
    columns['mod_id'] = []
    columns['destination'] = []
    columns['description'] = []

    for td in soup.find_all('td', {"data-type": "DisplayName"}):
        columns['description'].append(td.text)
        columns['destination'].append(MOD_DESTINATION)

    for a in soup.find_all('a', href=True):
        columns['mod_id'].append(a['href'].split("?id=", 1)[1])

    csvContent = zip(columns['mod_id'], columns['destination'], columns['description'])

    print("Found ", len(columns['mod_id']), " mods.")

with open('presetfile.csv', "w", newline='') as f:
    write = csv.writer(f)
    write.writerow(CSV_HEADERS)
    write.writerows(csvContent)