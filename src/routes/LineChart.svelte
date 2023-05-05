<script lang="ts">
	import { Icon } from "svelte-awesome";
	import type { EChartsOption, EChartsType } from "echarts";
	import EChart from "./EChart.svelte";
	import { dynamicPalette } from "./utils";

	import infoCircle from "svelte-awesome/icons/infoCircle";

	export let id: string;
	export let data: (string | number)[][];
	export let showAvg = true;
	export let title: string;
	export let subtitle: string;
	export let note: string | undefined = undefined;
	export let source: string;

	let instance: EChartsType;

	$: option = {
		legend: {
			show: false,
			selected: { "(Durchschnitt)": true },
		},
		grid: {
			top: 12,
			bottom: 96,
		},
		xAxis: {
			type: "category",
			axisLine: { show: false },
			axisTick: { show: false },
			data: Array.from({ length: 2021 - 1984 + 1 }, (_, i) => i + 1984),
		},
		yAxis: { scale: true },
		tooltip: {
			trigger: "axis",
			order: "valueDesc",
		},
		dataset: { source: data },
		series: Array.from(data.slice(1), ([id, ..._values]) => ({
			id,
			type: "line",
			seriesLayoutBy: "row",
		})),
		color: ["#d2d4d7", ...dynamicPalette],
		animationDuration: 400,
	} as EChartsOption;

	$: if (showAvg) {
		instance?.dispatchAction({
			type: "legendSelect",
			name: "(Durchschnitt)",
		});
	} else {
		instance?.dispatchAction({
			type: "legendUnSelect",
			name: "(Durchschnitt)",
		});
	}

	$: tooltip =
		note === undefined
			? `Datenquelle: ${source}`
			: `Anmerkung: ${note}. Datenquelle: ${source}`;
</script>

<div {id} class="h-72 scroll-mt-24">
	<div class="text-center">
		<div class="tooltip tooltip-bottom w-full" data-tip={tooltip}>
			<span
				class="inline-block max-w-[calc(100%-24px)] overflow-hidden text-ellipsis whitespace-nowrap align-middle text-base font-bold"
			>
				{title}
			</span>
			<span class="inline-block align-middle">
				<sup><Icon class="!fill-info" data={infoCircle} /></sup>
			</span>
		</div>
		<div class="text-sm">{subtitle}</div>
	</div>
	<EChart {option} replaceMerge={["series"]} bind:instance />
</div>
