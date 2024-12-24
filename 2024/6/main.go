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

func findNextMovePosition(guardPosition Position, mapping *[][]rune) *Position {
	newPosition := guardPosition
	var box rune
	lineLen := len((*mapping)[0])
	nbLines := len(*mapping)

	if guardPosition.Direction == "up" {
		if guardPosition.Y == 0 {
			return nil // found the solution
		}

		box = (*mapping)[guardPosition.Y-1][guardPosition.X]

		if box == '.' || box == 'X' {
			newPosition.Y = guardPosition.Y - 1
			return &newPosition
		} else if box == '#' {
			newPosition.Direction = "right"
			return findNextMovePosition(newPosition, mapping)
		}

	} else if guardPosition.Direction == "right" {
		if guardPosition.X == lineLen-1 {
			return nil
		}

		box = (*mapping)[guardPosition.Y][guardPosition.X+1]

		if box == '.' || box == 'X' {
			newPosition.X = guardPosition.X + 1
			return &newPosition
		} else if box == '#' {
			newPosition.Direction = "down"
			return findNextMovePosition(newPosition, mapping)
		}
	} else if guardPosition.Direction == "down" {
		if guardPosition.Y == nbLines-1 {
			return nil
		}

		box = (*mapping)[guardPosition.Y+1][guardPosition.X]

		if box == '.' || box == 'X' {
			newPosition.Y = guardPosition.Y + 1
			return &newPosition
		} else if box == '#' {
			newPosition.Direction = "left"
			return findNextMovePosition(newPosition, mapping)
		}
	} else if guardPosition.Direction == "left" {
		if guardPosition.X == 0 {
			return nil
		}

		box = (*mapping)[guardPosition.Y][guardPosition.X-1]

		if box == '.' || box == 'X' {
			newPosition.X = guardPosition.X - 1
			return &newPosition
		} else if box == '#' {
			newPosition.Direction = "up"
			return findNextMovePosition(newPosition, mapping)
		}
	} else {
		log.Println("else here")
		box = '-'
	}

	return nil
}

func countMovesUntilOutside(guardPosition Position, mapping *[][]rune) int {
	for {
		PrintPosition(guardPosition)
		PrintMapping(mapping)
		(*mapping)[guardPosition.Y][guardPosition.X] = 'X'
		next := findNextMovePosition(guardPosition, mapping)

		if next == nil {
			PrintPosition(guardPosition)
			PrintMapping(mapping)
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
	result := 0
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

	log.Println("mapping = ", mapping)
	result = countMovesUntilOutside(guard, &mapping)

	log.Println("result = ", result)
}
