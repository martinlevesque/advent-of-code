package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"strings"
)

type Position struct {
	X         int
	Y         int
	Direction string
}

func PrintPosition(pos Position) {
	log.Printf("Position - X: %d, Y: %d, Dir: %s\n", pos.X, pos.Y, pos.Direction)
}

func PrintMapping(mapping *[][]rune) {
	for _, line := range *mapping {
		for _, item := range line {
			fmt.Printf("%c ", item)
		}

		fmt.Printf("\n")
	}
}

func isObstruction(box rune) bool {
	return box == '#' || box == 'O'
}

func guardCanGoInBox(box rune) bool {
	return box == '.' || box == 'X'
}

func cloneMapping(mapping *[][]rune) [][]rune {
	original := *mapping
	clone := make([][]rune, len(original)) // Create a new top-level slice with the same length.

	for i := range original {
		// Copy each inner slice.
		clone[i] = make([]rune, len(original[i]))
		copy(clone[i], original[i])
	}

	return clone
}

func isLoop(guardPosition Position, mapping *[][]rune) bool {
	currentPosition := guardPosition
	history := []Position{}

	for {
		next, loopDetected := findNextMovePosition(currentPosition, mapping, &history)

		history = append(history, currentPosition)

		if loopDetected {
			return true
		}

		if next == nil {
			break
		} else {
			currentPosition = *next
		}
	}

	return false
}

func findLoops(guardPosition Position, mapping *[][]rune) int {
	result := 0

	for y, line := range *mapping {
		for x, item := range line {
			if item == 'X' && !(y == guardPosition.Y && x == guardPosition.X) {
				mappingWithObstruction := cloneMapping(mapping)
				mappingWithObstruction[y][x] = 'O'

				if isLoop(guardPosition, &mappingWithObstruction) {
					result += 1
				}
			}
		}
	}

	return result
}

func hasBeenTo(currentPosition Position, history *[]Position) bool {
	for _, p := range *history {
		if p.X == currentPosition.X && p.Y == currentPosition.Y && p.Direction == currentPosition.Direction {
			return true
		}
	}

	return false
}

func findNextMovePosition(guardPosition Position, mapping *[][]rune, history *[]Position) (*Position, bool) {
	newPosition := guardPosition
	var box rune
	lineLen := len((*mapping)[0])
	nbLines := len(*mapping)

	if hasBeenTo(guardPosition, history) {
		return nil, true
	}

	if guardPosition.Direction == "up" {
		if guardPosition.Y == 0 {
			return nil, false
		}

		box = (*mapping)[guardPosition.Y-1][guardPosition.X]

		if guardCanGoInBox(box) {
			newPosition.Y = guardPosition.Y - 1
			return &newPosition, false
		} else if isObstruction(box) {
			newPosition.Direction = "right"
			return findNextMovePosition(newPosition, mapping, history)
		}

	} else if guardPosition.Direction == "right" {
		if guardPosition.X == lineLen-1 {
			return nil, false
		}

		box = (*mapping)[guardPosition.Y][guardPosition.X+1]

		if guardCanGoInBox(box) {
			newPosition.X = guardPosition.X + 1
			return &newPosition, false
		} else if isObstruction(box) {
			newPosition.Direction = "down"
			return findNextMovePosition(newPosition, mapping, history)
		}
	} else if guardPosition.Direction == "down" {
		if guardPosition.Y == nbLines-1 {
			return nil, false
		}

		box = (*mapping)[guardPosition.Y+1][guardPosition.X]

		if guardCanGoInBox(box) {
			newPosition.Y = guardPosition.Y + 1
			return &newPosition, false
		} else if isObstruction(box) {
			newPosition.Direction = "left"
			return findNextMovePosition(newPosition, mapping, history)
		}
	} else if guardPosition.Direction == "left" {
		if guardPosition.X == 0 {
			return nil, false
		}

		box = (*mapping)[guardPosition.Y][guardPosition.X-1]

		if box == '.' || box == 'X' {
			newPosition.X = guardPosition.X - 1
			return &newPosition, false
		} else if isObstruction(box) {
			newPosition.Direction = "up"
			return findNextMovePosition(newPosition, mapping, history)
		}
	} else {
		box = '-'
	}

	return nil, false
}

func countMovesUntilOutside(guardPosition Position, mapping *[][]rune) int {
	history := []Position{}

	for {
		(*mapping)[guardPosition.Y][guardPosition.X] = 'X'
		next, loopDetected := findNextMovePosition(guardPosition, mapping, &history)

		if next == nil || loopDetected {
			break
		} else {
			guardPosition = *next
		}
	}

	result := 0

	for _, line := range *mapping {
		for _, item := range line {
			if item == 'X' {
				result += 1
			}
		}
	}

	return result
}

func main() {
	file, err := os.Open("input.txt")

	if err != nil {
		fmt.Printf("Error opening file: %v\n", err)
		return
	}

	defer file.Close()

	scanner := bufio.NewScanner(file)

	if err := scanner.Err(); err != nil {
		fmt.Printf("Error reading file: %v\n", err)
	}

	guard := Position{
		X:         -1,
		Y:         -1,
		Direction: "up",
	}
	mapping := [][]rune{}
	curY := 0

	for scanner.Scan() {
		line := scanner.Text() // Read the current line as a string

		lineRunes := []rune(line)
		mapping = append(mapping, lineRunes)

		positionGuard := strings.Index(line, "^")

		if positionGuard != -1 {
			guard.X = positionGuard
			guard.Y = curY
		}

		curY += 1
	}

	resultPart1 := countMovesUntilOutside(guard, &mapping)
	log.Println("result part 1 = ", resultPart1)
	resultPart2 := findLoops(guard, &mapping)

	log.Println("result part 2 = ", resultPart2)
}
