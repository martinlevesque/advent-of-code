
input_file = open('input.txt', 'r')

def build_compartments(bag: str) -> list:
    first_half_characters = bag[0:len(bag)//2]
    second_half_characters = bag[len(bag)//2:]

    assert first_half_characters + second_half_characters == bag

    return [first_half_characters, second_half_characters]

def find_unique_duplicates(compartment_1: str, compartment_2: str):
    duplicates = []

    for character in compartment_1:
        if character in compartment_2:
            duplicates.append(character)

    # remove duplicates
    return list(set(duplicates))

def item_value(item: str):
    # characters a to z are worth 1 to 26
    # and A to Z are worth 27 to 52
    if item.islower():
        return ord(item) - 96
    elif item.isupper():
        return ord(item) - 38

assert item_value('a') == 1
assert item_value('z') == 26
assert item_value('A') == 27
assert item_value('Z') == 52

def sum_items(items: list) -> int:
    return sum(map(item_value, items))

sum_errors = 0

for raw_line in input_file.readlines():
    bag = raw_line.strip()
    print(f"line: {bag}")

    compartments = build_compartments(bag)
    print(f"compartments: {compartments}")

    duplicates = find_unique_duplicates(compartments[0], compartments[1])

    sum_errors += sum_items(duplicates)

print(f"sum errors: {sum_errors}")

