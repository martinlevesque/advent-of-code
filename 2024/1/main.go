package main

import (
	"bufio"
	"fmt"
	"log"
	"math"
	"os"
	"sort"
	"strconv"
	"strings"
)

func similaryScore(leftNumber int, rightList *[]int) int {
	nbTimesAppearsRight := 0

	for _, rightNumber := range *rightList {
		if leftNumber == rightNumber {
			nbTimesAppearsRight += 1
		}
	}

	return leftNumber * nbTimesAppearsRight
}

func main() {
	log.Println("yo.")

	file, err := os.Open("input.txt")
	if err != nil {
		fmt.Printf("Error opening file: %v\n", err)
		return
	}
	defer file.Close()

	// Create a new scanner
	scanner := bufio.NewScanner(file)

	// Check for errors during scanning
	if err := scanner.Err(); err != nil {
		fmt.Printf("Error reading file: %v\n", err)
	}

	firstList := []int{}
	secondList := []int{}

	// Read and process the file line by line
	for scanner.Scan() {
		line := scanner.Text() // Get the current line as a string
		// Process the line
		fmt.Println(line) // Example: print each line
		parts := strings.Fields(line)

		if len(parts) != 2 {
			log.Fatalln("invalid line", line)
		}

		num1, err1 := strconv.Atoi(parts[0])
		num2, err2 := strconv.Atoi(parts[1])

		if err1 != nil || err2 != nil {
			log.Fatalln("error converting", err1)
		}

		firstList = append(firstList, num1)
		secondList = append(secondList, num2)
	}

	sort.Ints(firstList)
	sort.Ints(secondList)

	log.Println(firstList)
	log.Println(secondList)

	totalSumPart1 := 0
	sumPart2 := 0

	for index, firstListValue := range firstList {
		secondListValue := secondList[index]

		distance := math.Abs(float64(firstListValue) - float64(secondListValue))

		totalSumPart1 += int(distance)

		sumPart2 += similaryScore(firstListValue, &secondList)
	}

	log.Println("total sum part 1: ", totalSumPart1)
	log.Println("total sum part 2: ", sumPart2)
}
