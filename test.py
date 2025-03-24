import random
import json

names = [
    "Ethan Hunt", "James Bond", "Lara Croft", "Tony Stark", "Bruce Wayne", "Natasha Romanoff", "Clark Kent", 
    "Peter Parker", "Diana Prince", "Steve Rogers", "Wade Wilson", "Jean Grey", "Charles Xavier", "Logan Howlett", "Selina Kyle"
]
investment_purposes = ["Retirement Planning", "Wealth Growth", "Education Fund", "Real Estate Investment", "Business Expansion"]
risk_appetites = ["Low", "Moderate", "High"]
company_types = [["Small Cap", "Mid Cap"], ["Mid Cap", "Large Cap"], ["Small Cap", "Large Cap"]]
regions = ["America", "Europe", "Asia", "Australia"]
all_stock_names = ["nvidia", "amd", "intel", "microsoft", "zoom", "apple", "google", "tesla", "meta", "amazon"]
# all_stock_names = ["AIRESIS N",
#     "HOCN N",
#     "Cicor Technologie N",
#     "ams-OSRAM Br",
#     "Sensirion H Rg-144A",
#     "Implenia N",
#     "Idorsia Rg",
#     "V-ZUG Hldg Rg",
#     "Adecco Group N",
#     "Montana Aer Rg-Unty",
#     "Zwahlen et Mayr P",
#     "Medartis Hl Rg-Unty",
#     "medmix Rg-Unty",
#     "mobilezone hldg N",
#     "Sulzer N"
# ]
profiles = []
used_names = set()

for i in range(15):
    name = names[i]
    investment_purpose = random.choice(investment_purposes)
    risk_appetite = random.choice(risk_appetites)
    annual_income = random.randint(50000, 200000)
    investment_duration_years = random.randint(5, 30)
    preferred_company_type = random.choice(company_types)
    preferred_investment_regions = {
        region: random.randint(10, 70) for region in random.sample(regions, k=random.randint(2, 4))
    }
    
    available_stocks = all_stock_names.copy()
    stocks = []
    for _ in range(random.randint(3, 6)):
        if available_stocks:
            stock_name = random.choice(available_stocks)
            available_stocks.remove(stock_name)
            stocks.append({"name": stock_name, "number": random.randint(1, 50)})
    
    value = sum(stock["number"] * random.randint(50, 500) for stock in stocks)
    file_name = name.lower().replace(" ", "_") + ".json"
    
    profile = {
        "name": name,
        "investment_purpose": investment_purpose,
        "risk_appetite": risk_appetite,
        "annual_income": annual_income,
        "investment_duration_years": investment_duration_years,
        "preferred_company_type": preferred_company_type,
        "preferred_investment_regions": preferred_investment_regions,
        "stocks": stocks,
        "value": value,
        "file": file_name
    }
    
    profiles.append(profile)

print(json.dumps(profiles, indent=4))

with open("users.json", "w", encoding="utf-8") as file:
    file.write(json.dumps(profiles, indent=4))
