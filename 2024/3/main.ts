import * as fs from "node:fs";

const fileContent = fs.readFileSync("input.txt", "utf-8");

const regex = /mul\((\d{1,3}),(\d{1,3})\)/g;

let match;
let result: number = 0;

while ((match = regex.exec(fileContent)) !== null) {
	result += parseInt(match[1]) * parseInt(match[2]);
}

console.log(`result part 1: ${result}`);
