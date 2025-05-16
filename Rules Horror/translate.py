import json

with open("novel.json", "r") as f:
    novel = json.loads(f.read())
    print(len(novel["chapters"]))
    for chapter in novel["chapters"]:
        try:
            print(chapter["name"])
            print(chapter["messages"][len(chapter["messages"])-1]["routes"])
            print("-----------------------------")
        except KeyError:
            continue