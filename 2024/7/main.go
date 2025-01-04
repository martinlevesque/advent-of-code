package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"
)

type EquationElement struct {
	Number   int
	Operator string // + | * | ?
	Type     string // Number | Operator
}

type Equation struct {
	Result   int
	Elements []EquationElement
}

func (e Equation) Clone() Equation {
	// Create a new Equation
	cloned := Equation{
		Result:   e.Result,
		Elements: make([]EquationElement, len(e.Elements)), // Allocate space for Elements
	}

	// Copy each element in the Elements slice
	for i, elem := range e.Elements {
		cloned.Elements[i] = elem
	}

	return cloned
}

func stringToInt(s string) int {
	result, err := strconv.Atoi(s)

	if err != nil {
		log.Fatalln("inv result")
	}

	return result
}

func parseEquation(line string) Equation {
	sides := strings.Split(line, ":")

	if len(sides) != 2 {
		log.Fatalln("invalid sides")
	}

	result := stringToInt(sides[0])

	numbersString := strings.Split(strings.Trim(sides[1], " \t"), " ")

	elements := []EquationElement{}

	for i, elementString := range numbersString {
		elements = append(elements, EquationElement{Number: stringToInt(elementString), Operator: "?", Type: "Number"})

		if i < len(numbersString)-1 {
			elements = append(elements, EquationElement{Operator: "?", Type: "Operator"})
		}
	}

	return Equation{
		Result:   result,
		Elements: elements,
	}
}

func equationResultIncremental(currentResult int, nextNumber int, operator string) int {
	switch operator {
	case "+":
		return currentResult + nextNumber
	case "*":
		return currentResult * nextNumber
	case "||":
		return stringToInt(strconv.Itoa(currentResult) + strconv.Itoa(nextNumber))
	default:
		return currentResult // Default case for unhandled operators
	}
}

func resolveEquation(eq *Equation, currentResult int, index int, operators []string) *Equation {
	if currentResult > eq.Result {
		return nil
	}

	if index == len(eq.Elements) {
		if currentResult == eq.Result {
			return eq
		}

		return nil
	}

	element := &eq.Elements[index]

	if element.Type == "Operator" && element.Operator == "?" {
		for _, op := range operators {
			element.Operator = op

			// Compute the result for the next number
			nextResult := equationResultIncremental(currentResult, eq.Elements[index+1].Number, op)

			if result := resolveEquation(eq, nextResult, index+2, operators); result != nil {
				return result
			}
		}

		// Backtracking
		element.Operator = "?"
		return nil
	}

	// Continue to the next element
	return resolveEquation(eq, currentResult, index+1, operators)
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

	resultPart1 := 0
	resultPart2 := 0

	for scanner.Scan() {
		line := scanner.Text() // Read the current line as a string

		log.Println(line)
		eq := parseEquation(line)

		curP1 := resolveEquation(&eq, eq.Elements[0].Number, 0, []string{"+", "*"})

		if curP1 != nil {
			resultPart1 += curP1.Result
		}

		curP2 := resolveEquation(&eq, eq.Elements[0].Number, 0, []string{"+", "*", "||"})

		if curP2 != nil {
			resultPart2 += curP2.Result
		}
	}

	log.Println("result part 1 ", resultPart1)
	log.Println("result part 2 ", resultPart2)
}
