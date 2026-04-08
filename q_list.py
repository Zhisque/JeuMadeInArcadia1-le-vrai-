import json

def load_json_file(file_path):
    """
    Loads JSON data from a file and returns it as a Python object.
    
    :param file_path: Path to the JSON file
    :return: Python object (dict, list, etc.) or None if error occurs
    """
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            data = json.load(file)  # Parse JSON into Python object
            return data
    except FileNotFoundError:
        print(f"Error: File '{file_path}' not found.")
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON format. Details: {e}")
    except Exception as e:
        print(f"Unexpected error: {e}")
    return None

list = load_json_file("Minigames/QuizzTime/Assets/questions.json")
cats = {"geo":0, "hist":0, "lang":0, "film":0, "nature":0, "gi_trick":0, "science":0, "sport":0, "art":0, "jeux":0}

for elem in list:
    cats[elem["cat"]] += 1

for cat in cats:
    print(cat, "\t:", cats[cat])