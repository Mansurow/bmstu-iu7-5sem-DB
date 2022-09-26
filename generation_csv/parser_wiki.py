import requests
import wikipedia
from bs4 import BeautifulSoup
from random import randint

wikipedia.set_lang("ru")

def get_data_wiki_card_company(str):
    result = wikipedia.search(str)
    if not result:
        return []
    try:
        page = wikipedia.page(result[0])
    except:
        return []
    if str not in result[0]:
        return []
    url = page.url
    print("  ", url, str)
    # print("Company Wiki")
    response = requests.get(url=url)
    soup = BeautifulSoup(response.content, 'html.parser')
    table_card = soup.findAll('table', class_='infobox')
    name = soup.find(id="firstHeading").getText().split(" (компания)")[0]

    if table_card == []:
        return []
    tr_info = table_card[0].findAll('tr')
    country = "США"
    city = "Вашингтон"
    sphere = ""
    type = 2
    year_creation = ""
    number_employes = 0
    url = str.split(" ")[0].lower() + ".com"
    for tr in tr_info:
        try:
            names_1 = tr.findNext('th').getText()
            names_2 = tr.findNext('td').getText().split("\n")[1]
        except:
            continue
        if names_1 == "Тип":
            names_2 = names_2.lower()
            if "публичн" in names_2 or "акционерн" in names_2 or "oao" in names_2:
                type = 1
            elif "частн" in names_2 or "зао" in names_2:
                type = 2
            elif "дочерн" in names_2 or "филиал" in names_2 or "подразделение" in names_2:
                type = 3
            elif "ltd" in names_2 or "общество с ограниченной ответственностью" in names_2 or "ооо" == names_2:
                type = 4
            elif names_2 == "Kabushiki gaisha" or names_2 == "кабусики-гайся":
                type = 5
            elif "corporation" in names_2 or "корпорация" in names_2:
                type = 7
            elif "associated" in names_2 or "ассоциация" in names_2:
                type = 8
        elif names_1 == "Основание":
            if names_2.split("[")[0].split(" ")[-1] == "год":
                year_creation = int(names_2.split("[")[0].split(" ")[-2])
            else:
                try:
                    year_creation = int(names_2.split("[")[0].split(" ")[-1])
                except:
                    try:
                        year_creation = int(names_2.split("[")[0].split(" ")[0])
                    except:
                        year_creation = 0
            if year_creation < 1950:
                year_creation = randint(1950, 2020)
        elif names_1 == "Расположение":
            arr = names_2.split("\xa0")[-1].split(": ")
            country = arr[0].split(" ")[-1].split("[")[0]
            try:
                city = arr[1].split(" ")[0].split(",")[0].split(" ")[-1]
            except:
                city = arr[0].split(",")[0].split(" ")[-1]
        elif names_1 == "Отрасль":
            names_2 = names_2.lower()
            if "игр" in names_2:
                sphere = "Индустрия компьютерных игр"
            else:
                sphere = "Разработка программного обеспечения"
        elif names_1 == "Число сотрудников":
            arr = names_2.split("\xa0")
            try:
                if arr[0].split("▲")[0] == '':
                    number_employes = int(arr[0].split("▲")[1])
                else:
                    number_employes = int(arr[0].split("▲")[0].split("≈ ")[0].split(" ")[0].split("[")[0].split("-")[-1].split("<")[-1])
                number_employes = number_employes * 1000 + int(arr[1])
            except:
                number_employes = 0
        elif names_1 == "Сайт" and names_2 != "":
            url = names_2
        # print([names_1, names_2])
    if number_employes == 0:
        number_employes = randint(100, 5000)
    if country == "" or city == "":
        country = "США"
        city = "Вашингтон"

    # print(name)
    # print(country)
    # print(city)
    # print(sphere)
    # print(type)
    # print(year_creation)
    # print(number_employes)
    # print(url)
    # print()

    return [name,
            country,
            city,
            sphere,
            type,
            year_creation,
            number_employes,
            url]

def get_data_wiki_card_platform(name):
    result = wikipedia.search(name)
    if not result:
        return []
    page = wikipedia.page(result[0])
    if name not in result[0]:
        return []
    url = page.url
    print("  ", url, name)
    # print("Company Wiki")
    response = requests.get(url=url)
    soup = BeautifulSoup(response.content, 'html.parser')
    table_card = soup.findAll('table', class_='infobox')
    name = soup.find(id="firstHeading").getText().split(" (компания)")[0]
    if table_card == []:
        return []
    tr_info = table_card[0].findAll('tr')
    developer = ""
    type = ""
    year = 0
    for tr in tr_info:
        try:
            names_1 = tr.findNext('th').getText()
            names_2 = tr.findNext('td').getText().split("\n")[1]
        except:
            continue
        if names_1 == "Производитель":
            developer = names_2.split(",")[0]
        elif names_1 == "Тип":
            type = names_2.lower().split("[")[0]
        elif names_1 == "Дата выхода":
            if names_2.split("[")[0].split(" ")[-1] == "год":
                year = int(names_2.split("[")[0].split(" ")[-2])
            else:
                try:
                    year = int(names_2.split("[")[0].split(" ")[-1])
                except:
                    try:
                        year = int(names_2.split("[")[0].split(" ")[0])
                    except:
                        year = 0
            if year < 1950:
                year = randint(1980, 1990)
    # print(name)
    # print(developerid)
    # print(type)
    # print(year)
    return [name, developer, type, year]
# get_data_wiki_card("1-UP Studio")
# get_data_wiki_card_platform("PlayStation 5")
