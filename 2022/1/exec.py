
import array

input_file = open('input.txt', 'r')

cur_sum_calories = 0
elves_calories = []

for line in input_file.readlines():
    stripped_line = line.strip()

    if stripped_line == "":
        elves_calories.append(cur_sum_calories)

        cur_sum_calories = 0
    else:
        cur_sum_calories += int(stripped_line)

sorted_calories = sorted(elves_calories)
top_3_calories = sorted_calories[-3:]

print(f"final result: {sum(top_3_calories)}")