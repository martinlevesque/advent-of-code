import * as fs from "node:fs";

const fileContent = fs.readFileSync("input.txt", "utf-8");

function compute(content: string, withActivation: boolean): number {
	const regexWithActivation =
		/(mul\((\d{1,3}),(\d{1,3})\))|(do\(\))|(don't\(\))/g;
	const regexWithoutActivation = /mul\((\d{1,3}),(\d{1,3})\)/g;

	let regex: RegExp = regexWithActivation;

	if (!withActivation) {
		regex = regexWithoutActivation;
	}

	let match;
	let result: number = 0;
	let activated: boolean = true;

	while ((match = regex.exec(content)) !== null) {
		if (!withActivation) {
			result += parseInt(match[1]) * parseInt(match[2]);
		} else {
			if (match[0] === "do()") {
				activated = true;
			} else if (match[0] === "don't()") {
				activated = false;
			} else if (activated) {
				result += parseInt(match[2]) *
					parseInt(match[3]);
			}
		}
	}

	return result;
}

console.log(`result part 1: ${compute(fileContent, false)}`);
console.log(`result part 2: ${compute(fileContent, true)}`);
