export type Stringable = {
	toString(): string;
};

export type TargetedEvent<T> = Event & { currentTarget: EventTarget & T };

export type EChartSelectChangedEvent = {
	type: "selectchanged";
	fromAction: "select" | "toggleSelect" | "unselect";
	selected: {
		dataIndex: number[];
		seriesIndex: number;
	}[];
};

export function pseudoLog1p(x: number): number {
	return x >= 0 ? Math.log1p(x) : -Math.log1p(-x);
}

export function unique<T>(arr: T[]): T[] {
	return [...new Set(arr)];
}

type NumRange = { min: number; max: number };

function range(arr: number[]): NumRange {
	const values = arr.filter(Number.isFinite);
	return { min: Math.min(...values), max: Math.max(...values) };
}

export function rangeExt(arr: number[]): NumRange {
	const { min, max } = range(arr);
	if (min * max < 0) {
		const maxAbs = Math.max(Math.abs(min), Math.abs(max));
		return { min: -maxAbs, max: maxAbs };
	} else {
		return { min, max };
	}
}

export function whichMin(arr: number[]): number {
	let min = arr[0];
	let minIndex = 0;
	for (let i = 1; i < arr.length; i++) {
		if (arr[i] < min) {
			min = arr[i];
			minIndex = i;
		}
	}
	return minIndex;
}

export function objMap<T, U>(
	obj: { [k: string]: T },
	callbackfn: Function
): { [k: string]: U } {
	return Object.fromEntries(
		Object.entries(obj).map(([k, v]) => [k, callbackfn(v)])
	);
}
