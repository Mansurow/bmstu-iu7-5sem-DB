import os
import csv
from random import randint

from config import cur_dir, TYPIES, faker_ru, COUNT, spheres, types_con, COMPANY, faker_en
from parser_steam_pages import parsing_steam_games_data
from parser_wiki import get_data_wiki_card_company, get_data_wiki_card_platform

try:
    os.mkdir(cur_dir)
except:
    print("Directory /data exists")


def read_for_wiki(file):
    list = []
    with open(str(cur_dir + file), "r", encoding='utf-8') as file:
        for line in file:
            list.append(line.split("\n")[0])
    return list


def create_companies_data(count):
    list_companies = read_for_wiki("/games_companies.txt")
    com_data_arr = []
    i = 0
    for company in list_companies:
        try:
            com = get_data_wiki_card_company(company)
            if com:
                i += 1
                if i > count:
                    break
                com.insert(0, i)
                com_data_arr.append(com)
                COMPANY.append(company)
                print("  ", com)
        except:
            print("error", company)

    while i < count:
        i += 1
        name = faker_en.company()
        com = [
            i,
            name,
            faker_ru.country(),
            faker_ru.city(),
            spheres[randint(0, len(spheres) - 1)],
            randint(1, len(TYPIES)),
            randint(1980, 2022),
            randint(200, 10000),
            name + ".com"
        ]
        print("  ", com)
        com_data_arr.append(com)
    return com_data_arr


def create_fake_client_data(count):
    clients = []
    for i in range(count):
        user = faker_ru.simple_profile()
        fio = user['name'].split()
        client = [i + 1,
                  user['username'], fio[0], fio[1], fio[2],
                  faker_ru.country() + " " + faker_ru.address(),
                  user['sex'],
                  faker_ru.date(),
                  user['mail'],
                  user['mail'].split("@")[0],
                  faker_ru.password(),
                  faker_ru.date()]
        clients.append(client)
    return clients


def create_fake_sales(clients, games):
    sales = []
    for k in range(1, clients + 1):
        count_games = randint(1, games)
        i = 0
        arr_j = []
        while i < count_games:
            j = randint(1, games)
            if j not in arr_j:
                sales.append([k, j])
                i += 1
                arr_j.append(j)
    # print("  ", sales)
    return sales


def create_platforms(count):
    list_platforms = read_for_wiki("/platforms.txt")
    platforms = []

    i = 0
    for pl in list_platforms:
        platform = get_data_wiki_card_platform(pl)
        if platform:
            i += 1
            if i > count:
                break
            platform.insert(0, i)
            print("  ", platform)
            platforms.append(platform)

    while i < count:
        i += 1
        name = faker_en.word() + str(randint(1, 10))
        platform = [
            i,
            name,
            COMPANY[randint(0, len(COMPANY) - 1)],
            types_con[randint(0, len(types_con) - 1)],
            randint(1980, 2022)
        ]
        print("  ", platform)
        platforms.append(platform)

    return platforms


def printf_cvs(names, data, file, addindex=False):
    try:
        with open(str(cur_dir + file), "w", newline="", encoding='utf-8') as file:
            writer = csv.writer(file, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)

            writer.writerow(names)
            if addindex:
                for i in range(len(data)):
                    writer.writerow([i + 1, data[i]])
            else:
                for i in range(len(data)):
                    writer.writerow(data[i])
        res = "OK"
    except:
        res = "ERROR"
    return res


def link_tables(main, companies, index):
    for el in main:
        for company in COMPANY:
            if company in el[index] or company in el[index].split(" ")[0]:
                el[index] = company
                break

        find = [k for k, x in enumerate(COMPANY) if el[index] in x]
        if not find:
            data = get_data_wiki_card_company(el[index])
            if data != []:
                idata = len(COMPANY) + 1
                COMPANY.append(el[index])
                data.insert(0, idata)
                print(data)
                companies.append(data)
                el[index] = idata
        else:
            el[index] = find[0] + 1

        if isinstance(el[index], str):
            el[index] = randint(1, len(COMPANY))

def ask_read(file_name):
    flag_read = False
    if os.path.exists(cur_dir + file_name):
        ans = input("Перезаписать " + file_name + " Y/N: ")
        if ans == "Y" or ans == "Y":
            flag_read = True
    return flag_read


if __name__ == "__main__":
    companies = []
    games = []
    alldatacompanyies = ""

    flag_read = ask_read("\clients.csv")
    if flag_read:
        print("Clients Generating: Waiting...")
        clients = create_fake_client_data(COUNT)
        print("--- FINISH =", len(clients), "\n")

        print("Save in files ....")
        print("Clients - ", printf_cvs(
            ["id",
             "nick",
             "surname",
             "name",
             "middle_name",
             "address",
             "sex",
             "birthday",
             "email",
             "login",
             "password",
             "registration_date"],
            clients,
            "/clients.csv"))
        clients_len = len(clients)
    else:
        with open(cur_dir + "\clients.csv", "r", encoding="utf-8") as f:
            clients_len = len(f.readlines()) - 1

        print("Clients =", clients_len)

    flag_read = ask_read("\companies.csv")
    if flag_read:
        print("Companies Generating: Waiting...")
        companies = create_companies_data(COUNT)
        print(companies[3:])
        print("--- FINISH =", len(companies), "\n")

        print("Save in files ....")
        print("Types Company - ", printf_cvs(
            ["id",
             "name"],
            TYPIES,
            "/typies_company.csv", addindex=True))

        print("Companies - ", printf_cvs(
            ["id",
             "name",
             "country",
             "city",
             "sphere",
             "type",
             "year_creation",
             "number_employees",
             "url"],
            companies,
            "/companies.csv"))
    else:
        with open(cur_dir + "\companies.csv", "r", encoding="utf-8") as f:
            alldatacompanyies = f.readlines()
            for line in alldatacompanyies:
                COMPANY.append(line.split(",")[1].split("\"")[-1])

            COMPANY = COMPANY[1:]

        print("Companies =", len(COMPANY))

    flag_read = ask_read("\games.csv")
    if flag_read:
        print("Games Generating: Waiting 500 from steam...")
        games, categories, genres = parsing_steam_games_data(COUNT)
        print("--- FINISH games =", len(games), "\n",
              "   genres  =", len(genres), "\n",
              "categories =", len(categories), "\n")

        link_tables(games, companies, 3)
        link_tables(games, companies, 4)

        if companies:
            with open(str(cur_dir + "\companies.csv"), "a", newline="", encoding='utf-8') as file:
                writer = csv.writer(file, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)

                for i in range(len(companies)):
                    writer.writerow(companies[i])


        print("Save in files ....")
        print("Games - ", printf_cvs(
            ["id",
            "name",
            "type",
            "developer",
            "publisher",
            "req_age",
            "date_publish",
            "number_copies",
            "price"],
            games,
            "/games.csv"))

        print("Genres - ", printf_cvs(
            ["id",
             "name"],
            genres,
            "/genres.csv", addindex=True))

        print("Categories - ", printf_cvs(
            ["gameId",
             "genreId"],
            categories,
            "/categories.csv"))

        games_len = len(games)
    else:
        with open(cur_dir + "\games.csv", "r", encoding="utf-8") as f:
            for line in f.readlines():
                games.append(line.split(","))
            games = games[1:]
            games_len = len(games)
        print("Games =", games_len)
        # for g in games:
        #     print(g)

    flag_read = ask_read("\sales.csv")
    if flag_read:
        print("Sales Generating: Waiting...")
        sales = create_fake_sales(clients_len, games_len)
        print("--- FINISH =", len(sales), "\n")

        print("Save in files ....")
        print("Sales - ", printf_cvs(
            ["clientId",
             "gameId"],
            sales,
            "/sales.csv"))
    else:
        with open(cur_dir + "\sales.csv", "r", encoding="utf-8") as f:
            sales_len = len(f.readlines()) - 1
        print("Sales =", sales_len)

    flag_read = ask_read("\platforms.csv")
    if flag_read:
        print("Platforms Generating: Waiting...")
        platforms = create_platforms(COUNT)
        print("--- FINISH =", len(platforms), "\n")

        link_tables(platforms, companies, 2)

        print("Supports Generating: Waiting...")
        supports = create_fake_sales(games_len, len(platforms))
        print("--- FINISH =", len(supports), "\n")

        print("Supports - ", printf_cvs(
            ["gameId",
             "platformId"],
            supports,
            "/supports.csv"))

        print("Platforms - ", printf_cvs(
            ["id",
             "name",
             "manufacturer",
             "type",
             "year_production"],
            platforms,
            "/platforms.csv"))
    else:
        with open(cur_dir + "\platforms.csv", "r", encoding="utf-8") as f:
            platform_len = len(f.readlines()) - 1
        with open(cur_dir + "\supports.csv", "r", encoding="utf-8") as f:
            supports_len = len(f.readlines()) - 1
        print("Platforms =", platform_len)
        print("Supports =", supports_len)

