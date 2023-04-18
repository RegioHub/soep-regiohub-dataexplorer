<script lang="ts">
	import { Icon } from "svelte-awesome";
	import { registerMap, type EChartsOption, type EChartsType } from "echarts";
	import EChart from "./EChart.svelte";
	import { geoMercator } from "d3-geo";
	import { objMap, pseudoLog1p } from "./utils";

	import searchPlus from "svelte-awesome/icons/searchPlus";
	import searchMinus from "svelte-awesome/icons/searchMinus";
	import { mapGeo } from "./geodata";
	import nuts1Boundaries from "./assets/nuts1-boundaries.json";

	export let mapInstance: EChartsType | undefined = undefined;
	export let level: "nuts1" | "nuts3";
	export let data: { name: string; value: number }[];
	export let log = false;
	export let range: { min: number; max: number };
	export let title: string;
	export let subtitle: string;

	Object.values(mapGeo).forEach((geoJson) =>
		registerMap(geoJson.name, geoJson)
	);

	$: mapName = mapGeo[level].name;

	const project = geoMercator();

	const mapCenter = project([10.45, 51.29]);

	let isZoomable = false;

	function resetZoom(): void {
		mapInstance?.setOption({ geo: { center: mapCenter, zoom: 1 } });
	}

	function valueFormatter(value: number): string {
		const rescaled = log ? Math.expm1(value) : value;
		return Number.isNaN(rescaled)
			? "-"
			: rescaled.toFixed(2).replace(".00", "");
	}

	const pals = {
		geyser: [
			"#c7522b",
			"#d1773a",
			"#da9857",
			"#e3b77a",
			"#edd59f",
			"#fbf2c4",
			"#d0dcb5",
			"#aec4aa",
			"#85af97",
			"#539b8a",
			"#008585",
		],
		mako: [
			"#def5e5",
			"#a8e1bc",
			"#60ceac",
			"#3db4ad",
			"#3497a9",
			"#357ba2",
			"#395d9c",
			"#414081",
			"#382a54",
			"#26172a",
			"#0b0405",
		],
	};

	$: option = {
		tooltip: {
			trigger: "item",
			appendToBody: true,
			transitionDuration: 0.2,
		},
		visualMap: {
			...(log ? objMap(range, pseudoLog1p) : range),
			calculable: true,
			seriesIndex: [0],
			inRange: {
				color: range.min < 0 ? pals.geyser : pals.mako,
			},
			outOfRange: {
				color: "#e5e6e6",
			},
			orient: "horizontal",
			itemHeight: 320,
			left: "center",
			top: 16,
			backgroundColor: "rgba(255,255,255,0.6)",
			formatter: valueFormatter,
		},
		geo: {
			map: mapName,
			roam: isZoomable,
			projection: { project, unproject: project.invert },
			center: mapCenter,
			itemStyle: {
				areaColor: "#e5e6e6",
				borderColor: "#f2f2f2",
				borderWidth: 1,
			},
			emphasis: {
				label: {
					show: false,
				},
				itemStyle: {
					areaColor: "#f000b8",
				},
			},
			select: {
				label: {
					show: false,
				},
				itemStyle: {
					areaColor: "#c00093",
					borderWidth: 2,
					shadowBlur: 4,
					shadowColor: "#1f2937",
				},
			},
			top: 96,
			bottom: 32,
		},
		series: [
			{
				type: "map",
				name: title,
				selectedMode: "multiple",
				data: log
					? data.map(({ name, value }) => ({ name, value: pseudoLog1p(value) }))
					: data,
				tooltip: {
					valueFormatter,
				},
				geoIndex: 0,
			},
			{
				type: "lines",
				polyline: true,
				lineStyle: {
					color: "#fff",
					width: 1,
					shadowBlur: 2,
					shadowColor: "#1f2937",
					opacity: level === "nuts1" ? 0 : 1,
				},
				data: nuts1Boundaries,
				animation: false,
				tooltip: {
					extraCssText: "display: none",
				},
			},
		],
		animation: false,
	} as EChartsOption;
</script>

<h1 class="mt-4 text-lg font-bold">{title}</h1>

<div class="text-sm">{subtitle}</div>

<EChart {option} bind:instance={mapInstance} />

<div class="inline-flex items-center">
	<span class="form-control">
		<label class="label cursor-pointer">
			<input
				type="checkbox"
				class="toggle toggle-sm mr-2"
				bind:checked={isZoomable}
				on:change={resetZoom}
			/>

			{#each [searchPlus, searchMinus] as icon}
				<Icon
					class={`pl-1 text-base-content ${isZoomable ? "" : "opacity-50"}`}
					data={icon}
					label="Zoom aktivieren"
					scale={1.6}
				/>
			{/each}
		</label>
	</span>
</div>