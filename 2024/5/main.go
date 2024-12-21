package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"strings"
)

type PageOrdering struct {
	X string
	Y string
}

type PageUpdate struct {
	Updates []string
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
		Updates: parts,
	}
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

	for scanner.Scan() {
		line := scanner.Text() // Read the current line as a string

		log.Println(line)

		if strings.Contains(line, "|") {
			pageOrdering := parsePageOrdering(line)

			if _, ok := pageOrderingLookup[pageOrdering.X]; !ok {
				pageOrderingLookup[pageOrdering.X] = []PageOrdering{}
			}

			pageOrderingLookup[pageOrdering.X] = append(pageOrderingLookup[pageOrdering.X], pageOrdering)

			if _, ok := pageOrderingLookup[pageOrdering.Y]; !ok {
				pageOrderingLookup[pageOrdering.Y] = []PageOrdering{}
			}

			pageOrderingLookup[pageOrdering.Y] = append(pageOrderingLookup[pageOrdering.Y], pageOrdering)
		} else if strings.Contains(line, ",") {
			pageUpdate := parsePageUpdate(line)
			log.Println("new page update ", pageUpdate)
		}

	}

	for k, v := range pageOrderingLookup {
		log.Printf("%s -> %v\n", k, v)
	}

}
