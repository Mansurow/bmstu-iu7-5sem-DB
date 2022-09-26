import json
from random import randint

import requests
from config import faker_ru, URL_STEAM, POSTS_AGE, faker_en, type_game, COMPANY


def parsing_steam_games_data(count):
    genres_arr = []
    catigories_arr = []
    games_arr = []

    def get_steam_page(num):
        response = requests.get(URL_STEAM + str(num))
        if json.loads(response.text) == None:
            return None
        # print(URL_STEAM + str(num))
        return json.loads(response.text)[str(num)]

    def parsing_steam_page(i, json):
        game = []
        if json["success"]:
            data = json["data"]
            is_free = data["is_free"]
            name = data["name"]
            type = data["type"]
            req_age = data["required_age"]
            if req_age < POSTS_AGE[0]:
                req_age = POSTS_AGE[randint(0, len(POSTS_AGE) - 1)]
            try:
                developer = data["developers"][0]
                publisher = data["publishers"][0]
            except Exception:
                developer = publisher = "Valve"

            try:
                price = float(data["price_overview"]["initial"]) / 100
            except Exception:
                if is_free:
                    price = 0
                else:
                    price = randint(200, 2000)

            data_publish = data["release_date"]["date"]

            data_split = data_publish.split(" ")
            if data_split[1] == "Jan," or data_split[1] == "янв.":
                data_publish = data_split[0] + ".01." + data_split[2]
            elif data_split[1] == "Feb," or data_split[1] == "фев.":
                data_publish = data_split[0] + ".02." + data_split[2]
            elif data_split[1] == "Mar," or data_split[1] == "мар.":
                data_publish = data_split[0] + ".03." + data_split[2]
            elif data_split[1] == "Apr," or data_split[1] == "апр.":
                data_publish = data_split[0] + ".04." + data_split[2]
            elif data_split[1] == "May," or data_split[1] == "май.":
                data_publish = data_split[0] + ".05." + data_split[2]
            elif data_split[1] == "Jun," or data_split[1] == "июн.":
                data_publish = data_split[0] + ".06." + data_split[2]
            elif data_split[1] == "Jul," or data_split[1] == "июл.":
                data_publish = data_split[0] + ".07." + data_split[2]
            elif data_split[1] == "Aug," or data_split[1] == "авг.":
                data_publish = data_split[0] + ".08." + data_split[2]
            elif data_split[1] == "Sep," or data_split[1] == "сен.":
                data_publish = data_split[0] + ".09." + data_split[2]
            elif data_split[1] == "Oct," or data_split[1] == "окт.":
                data_publish = data_split[0] + ".10." + data_split[2]
            elif data_split[1] == "Nov," or data_split[1] == "нояб.":
                data_publish = data_split[0] + ".11." + data_split[2]
            elif data_split[1] == "Dec," or data_split[1] == "дек.":
                data_publish = data_split[0] + ".12." + data_split[2]

            try:
                categories = data["categories"]
            except:
                categories = []

            try:
                genres = data["genres"]
            except:
                genres = []

            try:
                number_rec = data["recommendations"]["total"]
            except:
                number_rec = 1

            game = [i + 1,
                    name,
                    type,
                    developer,
                    publisher,
                    req_age,
                    data_publish,
                    number_rec * randint(150, 1000),
                    price]
            print("  ", game)

            for genre in genres:
                if genre["description"] not in genres_arr:
                    genres_arr.append(genre["description"])
                    catigories_arr.append([i + 1, [k for k, x in enumerate(genres_arr) if genre["description"] in x][0] + 1])

            for category in categories:
                if category["description"] not in genres_arr:
                    genres_arr.append(category["description"])
                    catigories_arr.append([i + 1, [k for k, x in enumerate(genres_arr) if category["description"] in x][0] + 1])

        #    print("    ", genres_arr)
        #    print("    ", catigories_arr)
        # else:
        #     print("empty page!!!")
        return game

    i = 0
    # js = get_steam_page(1096900)
    # parsing_steam_page(1, js)
    j = 20
    while i < 500:
        try:
            js = get_steam_page(j)
            if js != None:
                g = parsing_steam_page(i, js)
                if g:
                    games_arr.append(g)
                    i += 1
            # else:
            #     print("page empty NULL!!!")
        except Exception:
            print("ERROR")
        finally:
            j += 10
        # js = get_steam_page(j)
        # try:
        #     if js != None:
        #         g = parsing_steam_page(i, js)
        #         if g != []:
        #             i += 1
        #     print(j)
        #     j += 10
        # except Exception as er:
        #     print(er)
        #     for el in js["data"]:
        #         print("   ", el, js["data"][el])
        #     break
    i += 1
    while i <= count:
        game = [i,
                faker_en.word(),
                type_game[randint(0, len(type_game) - 1)],
                COMPANY[randint(0, len(COMPANY) - 1)],
                COMPANY[randint(0, len(COMPANY) - 1)],
                POSTS_AGE[randint(0, len(POSTS_AGE) - 1)],
                faker_ru.date(pattern="%d.%m.%Y"),
                randint(200, 100000),
                randint(150, 50000) / 100]
        games_arr.append(game)
        print(game)

        count_genres = randint(1, len(genres_arr))
        k = 0
        arr_j = []
        while k < count_genres:
            j = randint(1, len(genres_arr))
            if j not in arr_j:
                catigories_arr.append([i, j])
                k += 1
                arr_j.append(j)

        i += 1


    print("asas", len(games_arr))
    return games_arr, catigories_arr, genres_arr

# parsing_steam_games_data(100)