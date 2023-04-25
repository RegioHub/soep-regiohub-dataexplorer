import type ColumnTable from "arquero/dist/types/table/column-table";

export type Stringable = {
	toString(): string;
};

export type TargetedEvent<T> = Event & { currentTarget: EventTarget & T };

export type EChartSelectchangedEvent = {
	type: "selectchanged";
	fromAction: "select" | "unselect";
	fromActionPayload: {
		type: "select" | "unselect";
		isFromClick?: boolean;
		seriesIndex?: number;
		dataIndexInside?: number;
		name?: string;
	};
	isFromClick: boolean;
	selected:
		| []
		| {
				seriesIndex: number;
				dataIndex: number[];
		  }[];
};

export const dynamicPalette = [
	"#db9d85",
	"#9db469",
	"#3dbeab",
	"#87aedf",
	"#da95cc",
];

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

export function objMap<K extends string, T, U>(
	obj: Record<K, T>,
	callbackfn: (value: T, key: K) => U
): Record<K, U> {
	return Object.fromEntries(
		(Object.entries(obj) as [K, T][]).map(([k, v]) => [k, callbackfn(v, k)])
	) as Record<K, U>;
}

export function toEChartDatasetRows(tbl: ColumnTable): (string | number)[][] {
	return Object.entries(tbl.data()).map(([name, value]) => [
		name,
		...value.data,
	]);
}
