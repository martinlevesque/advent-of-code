input_file = open('input.txt', 'r')

GAME_SCORES = {
    'win': 6,
    'loss': 0,
    'draw': 3
}

POINTS_SELECTION = {
    'rock': 1,
    'paper': 2,
    'scissors': 3
}

def evaluate_raw_selection(player_selection):
    if player_selection == 'A':
        return 'rock', POINTS_SELECTION['rock']
    elif player_selection == 'B':
        return 'paper', POINTS_SELECTION['paper']
    elif player_selection == 'C':
        return 'scissors', POINTS_SELECTION['scissors']

def evaluate_selection(player_selection, other_player_selection):
    if evaluate_raw_selection(player_selection):
        return evaluate_raw_selection(player_selection)
    elif player_selection == 'X':
        # need to lose
        if other_player_selection == 'A':
            return 'scissors', POINTS_SELECTION['scissors']
        elif other_player_selection == 'B':
            return 'rock', POINTS_SELECTION['rock']
        elif other_player_selection == 'C':
            return 'paper', POINTS_SELECTION['paper']
    elif player_selection == 'Y':
        # need to draw
        return evaluate_raw_selection(other_player_selection)
    elif player_selection == 'Z':
        # need to win
        if other_player_selection == 'A':
            return 'paper', POINTS_SELECTION['paper']
        elif other_player_selection == 'B':
            return 'scissors', POINTS_SELECTION['scissors']
        elif other_player_selection == 'C':
            return 'rock', POINTS_SELECTION['rock']

def evaluate_game(first_player_selection, second_player_selection):
    if first_player_selection == second_player_selection:
        return GAME_SCORES['draw']

    if first_player_selection == 'rock' and second_player_selection == 'scissors':
        return GAME_SCORES['win']
    elif first_player_selection == 'scissors' and second_player_selection == 'paper':
        return GAME_SCORES['win']
    elif first_player_selection == 'paper' and second_player_selection == 'rock':
        return GAME_SCORES['win']

    return GAME_SCORES['loss']


def score_game(first_player_selection, second_player_selection):
    selection_name_player_1, selection_value_player_1 = evaluate_selection(first_player_selection, second_player_selection)
    selection_name_player_2, selection_value_player_2 = evaluate_selection(second_player_selection, first_player_selection)

    print(f"Player 1 selected {selection_name_player_1} ({selection_value_player_1})")
    print(f"Player 2 selected {selection_name_player_2} ({selection_value_player_2})")

    game_score = evaluate_game(selection_name_player_2, selection_name_player_1)

    print(f"Game score: {game_score}")

    return game_score + selection_value_player_2


score_games = []

for line in input_file.readlines():
    items = line.strip().split(' ')

    first_item = items[0]
    second_item = items[1]

    cur_score_game = score_game(first_item, second_item)
    score_games.append(cur_score_game)

print(f"Final score: {sum(score_games)}")
assert sum(score_games) == 13193
