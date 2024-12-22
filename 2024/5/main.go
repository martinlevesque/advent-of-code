package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"
)

type PageOrdering struct {
	X string
	Y string
}

type PageUpdate struct {
	Pages []string
}

func parsePageOrdering(line string) PageOrdering {
	parts := strings.Split(line, "|")

	return PageOrdering{
		X: parts[0],
		Y: parts[1],
	}
}

func parsePageUpdate(line string) PageUpdate {
	parts := strings.Split(line, ",")

	return PageUpdate{
		Pages: parts,
	}
}

func updateInCorrectOrder(update PageUpdate, orderings *map[string][]PageOrdering) bool {
	for kIndex, kItem := range update.Pages {
		for jIndex, jItem := range update.Pages {
			if jIndex <= kIndex {
				continue
			}

			jOrderings := (*orderings)[jItem]

			for _, orderingItem := range jOrderings {
				if kItem == orderingItem.Y && jItem == orderingItem.X {
					return false
				}
			}
		}
	}

	return true
}

func getMiddleItem(arr []string) string {
	if len(arr) == 0 {
		return "" // Return an empty string if the array is empty
	}

	middleIndex := len(arr) / 2

	return arr[middleIndex]
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

	pageOrderingLookup := make(map[string][]PageOrdering)
	result := 0

	for scanner.Scan() {
		line := scanner.Text() // Read the current line as a string

		if strings.Contains(line, "|") {
			pageOrdering := parsePageOrdering(line)

			if _, ok := pageOrderingLookup[pageOrdering.X]; !ok {
				pageOrderingLookup[pageOrdering.X] = []PageOrdering{}
			}

			pageOrderingLookup[pageOrdering.X] = append(pageOrderingLookup[pageOrdering.X], pageOrdering)
		} else if strings.Contains(line, ",") {
			pageUpdate := parsePageUpdate(line)

			if updateInCorrectOrder(pageUpdate, &pageOrderingLookup) {
				middleNumber, _ := strconv.Atoi(getMiddleItem(pageUpdate.Pages))

				result += middleNumber
			}
		}

	}

	log.Println("result = ", result)

}
