import json
import codecs

with open('currencies.json', encoding='utf-8-sig') as d:
    data1 = json.load(d)

with open('currenciesInfo.json', encoding='utf-8-sig') as d:
    data2 = json.load(d)

with open('countries.json', encoding='utf-8-sig') as d:
    countries = json.load(d)

result = {}

for currency in data1:
    for currencyInfo in data2:                    
        if (currencyInfo["Code"]).lower()==currency.lower():
            result[currency] = currencyInfo
            if("CountryName" in currencyInfo):
                for country in countries:
                    if(country["name"].lower()==currencyInfo["CountryName"].lower()):
                        result[currency]['CountryCode'] = country["code"]

with open('generated/currencies.json', 'w', encoding='utf8') as json_file:
    json.dump(result, json_file, ensure_ascii=False, indent=2)

print("Done")
input()