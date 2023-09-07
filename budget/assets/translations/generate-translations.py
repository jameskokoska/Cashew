import csv
import json
import os
import requests

dir_path = os.path.dirname(os.path.realpath(__file__)) + "\\"

csv_file_name = 'translations.csv'

google_sheets_url = 'https://docs.google.com/spreadsheets/d/1QQqt28cmrby6JqxLm-oxUXCuM3alniLJ6IRhcPJDOtk/gviz/tq?tqx=out:csv'

print("Downloading CSV...")

response = requests.get(google_sheets_url)

if response.status_code == 200:
    with open(dir_path + csv_file_name, 'wb') as csv_file:
        csv_file.write(response.content)
    print('CSV file downloaded successfully')
else:
    print('Failed to download CSV - status code: ', response.status_code)

print("Reading", dir_path + csv_file_name)


# Read the CSV file
with open(dir_path + csv_file_name, 'r', encoding='utf-8') as file:
    reader = csv.reader(file)
    rows = list(reader)

# Get the header row containing the languages
languages = rows[0][1:]

# Generate the output files
current_lang_index = 1
for lang in languages:
    print("Current Language - " + lang)
    current_lang_data = {}
    for row in rows[2:]:
        current_lang_data[row[0]] = row[current_lang_index]

    # Write the JSON file
    with open(dir_path + "generated/" + lang + ".json", 'w', encoding='utf-8') as file:
        json.dump(current_lang_data, file, indent=2, ensure_ascii=False)

    current_lang_index += 1

print("Done!")
