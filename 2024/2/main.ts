import * as fs from "fs";

function directionOf(firstItem: number, secondItem: number): string {
	if (secondItem < firstItem) {
		return "decreasing";
	} else {
		return "increasing";
	}
}

function reportSafe(report: string[]): boolean {
	let direction: string = "";

	for (let i = 0; i < report.length - 1; ++i) {
		if (i == report.length - 1) {
			continue;
		}

		const item = report[i];

		let currentItemI = parseInt(item);
		let nextItemI = parseInt(report[i + 1]);

		if (nextItemI == currentItemI) {
			return false;
		}

		let currentDirection = directionOf(currentItemI, nextItemI);

		if (direction == "") {
			direction = directionOf(currentItemI, nextItemI);
		} else if (currentDirection != direction) {
			return false;
		}

		const distance = Math.abs(currentItemI - nextItemI);

		if (distance < 1 || distance > 3) {
			return false;
		}
	}

	return true;
}

interface Row {
	report: string[];
}

const fileContent = fs.readFileSync("input.txt", "utf-8");

// Split the file into lines and process each line
const rows: Array<Row> = fileContent
	.split("\n") // Split by new lines
	.filter((line: string) => line.trim() !== "") // Remove empty lines
	.map((line: string) => {
		const report = line.split(" "); // Split by space

		return {
			report,
		};
	})
	.filter((item: Row) => {
		return reportSafe(item.report);
	});

const sumPart1 = rows.length;

console.log(`sum part 1: ${sumPart1}`);
