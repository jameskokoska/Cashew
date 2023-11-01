import json
import codecs

with open('currencies.json', encoding='utf-8-sig') as d:
    data1 = json.load(d)

with open('currenciesInfo.json', encoding='utf-8-sig') as d:
    data2 = json.load(d)

with open('currenciesInfo2.json', encoding='utf-8-sig') as d:
    data3 = json.load(d)

with open('countries.json', encoding='utf-8-sig') as d:
    countries = json.load(d)

result = {}
# "Currency": "Dollar",
# "Code": "USD",
# "Symbol": "$", (optional)
# "CountryName": "United States", (optional)
# "CountryCode": "US", (optional - used so the locale gets the current currency)
for currency in data1:
    found = False
    for currencyInfo in data2:
        if (currencyInfo["Code"]).lower()==currency.lower():
            found = True
            result[currency] = {
                "Currency": currencyInfo["Currency"],
                "Code": currencyInfo["Code"],
                "Symbol": currencyInfo["Symbol"],
            }
            if("CountryName" in currencyInfo):
                result[currency]["CountryName"] = currencyInfo["CountryName"]
                for country in countries:
                    if(country["name"].lower()==currencyInfo["CountryName"].lower()):
                        result[currency]['CountryCode'] = country["code"]
    if found==False:
        if currency.upper() in data3:
            dataPoint = data3[currency.upper()]
            result[currency] = {
                "Currency" : dataPoint["name"],
                "Code": dataPoint["code"],
                "Symbol": dataPoint["symbol_native"],
                # "CountryName": dataPoint["name"],
            }
        else:
            result[currency] = {
                "Currency" : data1[currency],
                "Code": currency,
                "NotKnown": True,
            }
    if currency in result and "Symbol" in result[currency] and result[currency]["Symbol"] == result[currency]["Code"]:
        del result[currency]["Symbol"]

with open('generated/currencies.json', 'w', encoding='utf8') as json_file:
    json.dump(result, json_file, ensure_ascii=False, indent=2)

print("Done")
input()
