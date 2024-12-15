package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
)

type ResultEntry struct {
	rowBegin    int
	columnBegin int
	rowEnd      int
	columnEnd   int
}

type Coord struct {
	y int
	x int
}

func reverseString(s string) string {
	b := []byte(s)

	for i, j := 0, len(b)-1; i < j; i, j = i+1, j-1 {
		b[i], b[j] = b[j], b[i]
	}

	return string(b)
}

func stringWith(matrix *[][]rune, coords []Coord) string {
	runesResult := []rune{}

	for _, coord := range coords {
		runesResult = append(runesResult, (*matrix)[coord.y][coord.x])
	}

	return string(runesResult)
}

func findInRowPart1(rowIndex int, matrix *[][]rune, target string) []ResultEntry {
	targetRunes := []rune(target)
	targetLen := len(targetRunes)
	result := []ResultEntry{}

	lenRow := len((*matrix)[rowIndex])

	// loop over columns
	for j := 0; j < lenRow; j++ {
		// from left to right
		if j+targetLen <= lenRow && string((*matrix)[rowIndex][j:j+targetLen]) == string(targetRunes) {
			result = append(result, ResultEntry{
				rowBegin:    rowIndex,
				columnBegin: j,
				rowEnd:      rowIndex,
				columnEnd:   j + targetLen - 1,
			})
		} else if j+targetLen <= lenRow && reverseString(string((*matrix)[rowIndex][j:j+targetLen])) == string(targetRunes) {

			result = append(result, ResultEntry{
				rowBegin:    rowIndex,
				columnBegin: j + targetLen - 1,
				rowEnd:      rowIndex,
				columnEnd:   j,
			})
		}

		if rowIndex+targetLen <= len(*matrix) {
			coords := []Coord{
				Coord{y: rowIndex, x: j},
				Coord{y: rowIndex + 1, x: j},
				Coord{y: rowIndex + 2, x: j},
				Coord{y: rowIndex + 3, x: j},
			}

			if stringWith(matrix, coords) == string(targetRunes) {
				result = append(result, ResultEntry{
					rowBegin:    rowIndex,
					columnBegin: j,
					rowEnd:      rowIndex + 3,
					columnEnd:   j,
				})
			} else if reverseString(stringWith(matrix, coords)) == string(targetRunes) {
				result = append(result, ResultEntry{
					rowBegin:    rowIndex + 3,
					columnBegin: j,
					rowEnd:      rowIndex,
					columnEnd:   j,
				})
			}
		}

		if rowIndex+targetLen <= len(*matrix) && j+targetLen <= lenRow {
			// diag
			coords := []Coord{
				Coord{y: rowIndex, x: j},
				Coord{y: rowIndex + 1, x: j + 1},
				Coord{y: rowIndex + 2, x: j + 2},
				Coord{y: rowIndex + 3, x: j + 3},
			}

			if stringWith(matrix, coords) == string(targetRunes) {
				result = append(result, ResultEntry{
					rowBegin:    rowIndex,
					columnBegin: j,
					rowEnd:      rowIndex + 3,
					columnEnd:   j + 3,
				})
			} else if reverseString(stringWith(matrix, coords)) == string(targetRunes) {
				result = append(result, ResultEntry{
					rowBegin:    rowIndex + 3,
					columnBegin: j + 3,
					rowEnd:      rowIndex,
					columnEnd:   j,
				})
			}
		}

		if rowIndex+targetLen <= len(*matrix) && j-targetLen+1 >= 0 {
			// diag
			coords := []Coord{
				Coord{y: rowIndex, x: j},
				Coord{y: rowIndex + 1, x: j - 1},
				Coord{y: rowIndex + 2, x: j - 2},
				Coord{y: rowIndex + 3, x: j - 3},
			}

			if stringWith(matrix, coords) == string(targetRunes) {
				result = append(result, ResultEntry{
					rowBegin:    rowIndex,
					columnBegin: j,
					rowEnd:      rowIndex + 3,
					columnEnd:   j - 3,
				})
			} else if reverseString(stringWith(matrix, coords)) == string(targetRunes) {
				result = append(result, ResultEntry{
					rowBegin:    rowIndex + 3,
					columnBegin: j - 3,
					rowEnd:      rowIndex,
					columnEnd:   j,
				})
			}
		}
	}

	return result
}

func findInRowPart2(rowIndex int, m *[][]rune) int {
	lenRow := len((*m)[rowIndex])
	result := 0

	// loop over columns
	for j := 0; j < lenRow; j++ {

		// look for a A
		if rowIndex >= 1 && j < lenRow-1 && j > 0 && rowIndex < len(*m)-1 {
			if (*m)[rowIndex][j] == 'A' {
				if (((*m)[rowIndex-1][j-1] == 'M' && (*m)[rowIndex+1][j+1] == 'S') ||
					((*m)[rowIndex-1][j-1] == 'S' && (*m)[rowIndex+1][j+1] == 'M')) &&
					(((*m)[rowIndex+1][j-1] == 'M' && (*m)[rowIndex-1][j+1] == 'S') ||
						((*m)[rowIndex+1][j-1] == 'S' && (*m)[rowIndex-1][j+1] == 'M')) {
					result += 1
				}
			}
		}
	}

	return result
}

func findXmas(matrix *[][]rune) (int, int) {
	result := []ResultEntry{}
	resultPart2 := 0

	for i, _ := range *matrix {
		resultPart1 := findInRowPart1(i, matrix, "XMAS")
		resultPart2 += findInRowPart2(i, matrix)

		for _, entry := range resultPart1 {
			result = append(result, entry)
		}
	}

	return len(result), resultPart2
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

	var matrix [][]rune

	for scanner.Scan() {
		line := scanner.Text()       // Read the current line as a string
		row := []rune(line)          // Convert the line into a slice of runes (characters)
		matrix = append(matrix, row) // Append the row to the matrix
	}

	resultPart1, resultPart2 := findXmas(&matrix)

	log.Println("result part 1 ", resultPart1)
	log.Println("result part 2 ", resultPart2)
}
