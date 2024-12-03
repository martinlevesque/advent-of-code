package main

import (
	"bufio"
	"fmt"
	"log"
	"math"
	"os"
	"strconv"
	"strings"
)

func directionOf(firstItem int, secondItem int) string {
	if secondItem < firstItem {
		return "decreasing"
	} else {
		return "increasing"
	}
}

func reportSafe(report []string) bool {

	direction := ""

	for index, item := range report {
		if index == len(report)-1 {
			continue
		}

		currentItemI, _ := strconv.Atoi(item)
		nextItemI, _ := strconv.Atoi(report[index+1])

		if nextItemI == currentItemI {
			return false
		}

		currentDirection := directionOf(currentItemI, nextItemI)

		if direction == "" {
			direction = directionOf(currentItemI, nextItemI)
		} else if currentDirection != direction {
			return false
		}

		distance := math.Abs(float64(currentItemI) - float64(nextItemI))

		if distance < 1 || distance > 3 {
			return false
		}
	}

	return true
}

func main() {
	log.Println("yo.")

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

	sumPart1 := 0

	for scanner.Scan() {
		line := scanner.Text() // Get the current line as a string
		// Process the line
		fmt.Println(line) // Example: print each line
		parts := strings.Fields(line)

		if reportSafe(parts) {
			sumPart1 += 1
		}
	}

	log.Println("sum part 1 ", sumPart1)
}
