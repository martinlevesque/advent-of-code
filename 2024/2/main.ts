import * as fs from "node:fs";

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

		const currentItemI = parseInt(item);
		const nextItemI = parseInt(report[i + 1]);

		if (nextItemI == currentItemI) {
			return false;
		}

		const currentDirection = directionOf(currentItemI, nextItemI);

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

function resultOf(
	content: string,
	filterCallback: (_: Row) => boolean,
): number {
	const rows: Array<Row> = content
		.split("\n") // Split by new lines
		.filter((line: string) => line.trim() !== "") // Remove empty lines
		.map((line: string) => {
			const report = line.split(" "); // Split by space

			return {
				report,
			};
		})
		.filter((item: Row) => {
			return filterCallback(item);
		});

	return rows.length;
}

const sumPart1 = resultOf(fileContent, (item: Row) => {
	return reportSafe(item.report);
});

function cloneAndRemove<T>(arr: T[], index: number): T[] {
	// Ensure the index is within bounds
	if (index < 0 || index >= arr.length) {
		throw new Error("Index out of bounds");
	}

	return [...arr.slice(0, index), ...arr.slice(index + 1)];
}

const sumPart2 = resultOf(fileContent, (item: Row) => {
	const possibleReports: Array<Row> = [];

	possibleReports.push(item);

	item.report.forEach((_, index) => {
		const p = cloneAndRemove(item.report, index);
		possibleReports.push({ report: p });
	});

	return possibleReports.some((r) => reportSafe(r.report));
});

console.log(`sum part 1: ${sumPart1}`);
console.log(`sum part 2: ${sumPart2}`);
