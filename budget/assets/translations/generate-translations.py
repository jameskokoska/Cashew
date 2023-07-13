import csv
import json

csv_file = 'translations.csv'

print("Reading", csv_file)

# Read the CSV file
with open(csv_file, 'r', encoding='utf-8') as file:
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
    with open("generated/" + lang + ".json", 'w', encoding='utf-8') as file:
        json.dump(current_lang_data, file, indent=2, ensure_ascii=False)
        
    current_lang_index+=1

print("Done!")
input()
