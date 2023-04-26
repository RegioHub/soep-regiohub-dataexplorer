<script lang="ts">
	import { Icon } from "svelte-awesome";
	import { escape as aqEscape, table as aqTable } from "arquero";
	import type { Struct } from "arquero/dist/types/op/op-api";
	import type { EChartsType } from "echarts";
	import LineChart from "./LineChart.svelte";
	import Map from "./Map.svelte";
	import DiscreteSlider from "./DiscreteSlider.svelte";
	import {
		dynamicPalette,
		objMap,
		rangeExt,
		toEChartDatasetRows,
		unique,
		whichMin,
		type TargetedEvent,
	} from "./utils";

	import lineChart from "svelte-awesome/icons/lineChart";
	import sliders from "svelte-awesome/icons/sliders";
	import logo from "./assets/logo.svg";
	import metadata from "./metadata.json";
	import dataObj from "./assets/data.json";
	import avgData from "./assets/data-avg.json";
	import { regionNames } from "./geodata";

	const vars = Object.keys(metadata) as (keyof typeof metadata)[];

	const levels = ["nuts1", "nuts3"] as const;
	const levelLabels = {
		nuts1: "▲ Länder",
		nuts3: "Kreise ▼",
	};
	let level: (typeof levels)[number] = levels[1];

	const dataTbls = objMap(dataObj, (levelData) =>
		objMap(levelData, (data) => aqTable(data))
	);

	const dataTblsWide = objMap(dataTbls, (levelData, level) =>
		objMap(levelData, (tbl) => {
			const tblWide = tbl.groupby("year").pivot("name", "value");
			const nonMissingRegions = tblWide
				.columnNames()
				.filter((name) => name !== "year");
			const fillerValues = Array.from({ length: tblWide.numRows() }, () => NaN);
			const fillerCols = Object.fromEntries(
				regionNames[level]
					.filter((name) => !nonMissingRegions.includes(name))
					.map((name) => [name, fillerValues])
			);
			return aqTable({ ...tblWide.columns(), ...fillerCols });
		})
	);

	let mapInstance: EChartsType;

	let mapVar = vars[0];

	let mapYears = unique(dataObj.nuts1[mapVar].year).sort((a, b) => a - b);

	// RangeSlider values prop takes an array
	let mapYearNth = [0];
	$: mapYear = mapYears[mapYearNth[0]];

	let mapLogScale = false;
	let mapShowHospitals = false;

	$: mapData = dataTbls[level][mapVar]
		.filter(aqEscape((d: Struct) => d.year === mapYear))
		.select("name", "value")
		.objects() as { name: string; value: number }[];

	// Same range across years, don't use mapData
	$: mapRange = rangeExt(dataObj[level][mapVar].value);

	function handleMapVarChange(_event: TargetedEvent<HTMLSelectElement>): void {
		mapYears = unique(dataObj.nuts1[mapVar].year).sort((a, b) => a - b);

		const newYearNth = mapYears.indexOf(mapYear);
		mapYearNth =
			newYearNth >= 0
				? [newYearNth]
				: [whichMin(mapYears.map((y) => Math.abs(y - mapYear)))];

		document
			.querySelector("#" + mapVar + "-linechart")
			?.scrollIntoView({ behavior: "smooth" });
	}

	let selectedRegions: string[] = [];

	function unselectAllRegions(): void {
		mapInstance.dispatchAction({
			type: "unselect",
			name: selectedRegions,
		});
	}

	let lineChartsShowAvg = true;
</script>

<svelte:head>
	<title>SOEP RegioHub Data Explorer</title>
</svelte:head>

<div
	class="drawer-mobile drawer drawer-end h-[calc(100vh-52px)] overflow-hidden"
>
	<input id="chart-pane" type="checkbox" class="drawer-toggle" />

	<div class="drawer-content flex flex-col">
		<div class="drawer-mobile drawer">
			<input id="sidebar" type="checkbox" class="drawer-toggle" />

			<div class="drawer-content flex flex-col">
				<span class="flex h-16 items-center justify-between p-4 lg:hidden">
					<label
						for="sidebar"
						class="btn-ghost drawer-button btn-sm btn-square btn mr-4"
					>
						<Icon data={sliders} label="Options" scale={1.2} />
					</label>
					<img
						class="h-10"
						src={logo}
						alt="Leibniz ScienceCampus SOEP RegioHub Logo"
					/>
					<label
						for="chart-pane"
						class="btn-ghost drawer-button btn-sm btn-square btn ml-4"
					>
						<Icon data={lineChart} label="Line charts" scale={1.2} />
					</label>
				</span>

				<div class="flex h-full flex-col items-center overflow-hidden py-4">
					<Map
						{level}
						data={mapData}
						log={mapLogScale}
						range={mapRange}
						{...metadata[mapVar]}
						bind:instance={mapInstance}
						bind:selectedRegions
					/>

					<div class="mb-4 mt-8 w-80 sm:w-96">
						<DiscreteSlider options={mapYears} bind:selected={mapYearNth} />
					</div>
				</div>
			</div>

			<div class="drawer-side">
				<label for="sidebar" class="drawer-overlay" />
				<div class="menu w-80 bg-base-100 p-4 lg:w-72">
					<img src={logo} alt="Leibniz ScienceCampus SOEP RegioHub Logo" />

					<div class="divider invisible" />

					<div class="form-control mb-4 w-full">
						<label class="input-group input-group-vertical">
							<span class="label-text">Indikator</span>
							<select
								class="select-bordered select overflow-hidden text-ellipsis text-base"
								bind:value={mapVar}
								on:change={handleMapVarChange}
							>
								{#each vars as x}
									<option value={x}>{metadata[x].title}</option>
								{/each}
							</select>
						</label>
					</div>

					<div class="form-control">
						<label class="label cursor-pointer justify-start">
							<input
								type="checkbox"
								class="toggle toggle-sm mr-2"
								bind:checked={mapLogScale}
							/>
							<span class="label-text">Logarithmische Farbskala</span>
						</label>
					</div>

					<div class="form-control mb-4" class:invisible={true}>
						<label class="label cursor-pointer justify-start">
							<input
								type="checkbox"
								class="toggle toggle-sm mr-2"
								bind:checked={mapShowHospitals}
							/>
							<span class="label-text">Krankenhäuser anzeigen</span>
						</label>
					</div>

					<div class="btn-group w-full">
						{#each levels as l}
							<!-- svelte-ignore a11y-click-events-have-key-events -->
							<label
								class="btn-ghost btn w-1/2"
								class:btn-disabled={level === l}
								on:click={unselectAllRegions}
							>
								{levelLabels[l]}
								<input
									type="radio"
									class="hidden"
									name="level"
									value={l}
									bind:group={level}
								/>
							</label>
						{/each}
					</div>

					<div class="divider invisible" />

					<button
						class="btn-ghost btn-sm btn w-full normal-case"
						on:click={unselectAllRegions}
					>
						Auswahl aufheben
					</button>
				</div>
			</div>
		</div>
	</div>

	<div class="drawer-side">
		<label for="chart-pane" class="drawer-overlay" />

		<div class="menu w-11/12 px-4 py-0 lg:w-[calc((100vw-18rem)*9/16)]">
			<div class="sticky top-0 z-50 flex h-24 items-center bg-base-100 py-4">
				<div class="w-[calc(100%-192px)]">
					{#each selectedRegions.map( (v, i) => [v, dynamicPalette[i]] ) as [legendKey, legendColour]}
						<span class="mr-2">
							<span class="whitespace-nowrap">
								<span
									class="inline-block h-3 w-3 rounded-full"
									style={`background-color: ${legendColour};`}
								/>
								{legendKey}
							</span>
						</span>
					{/each}
				</div>

				<div class="form-control w-44">
					<label class="label cursor-pointer">
						<input
							type="checkbox"
							class="toggle toggle-sm mr-2"
							bind:checked={lineChartsShowAvg}
						/>
						<span class="label-text">Bundesdurchschnitt</span>
					</label>
				</div>
			</div>

			<div class="grid gap-0 md:grid-cols-2">
				{#each vars as yVar}
					<LineChart
						id={yVar + "-linechart"}
						data={[
							...avgData[level][yVar],
							...toEChartDatasetRows(
								dataTblsWide[level][yVar].select(selectedRegions)
							),
						]}
						showAvg={lineChartsShowAvg}
						{...metadata[yVar]}
					/>
				{/each}
			</div>
		</div>
	</div>
</div>

<footer class="footer h-[52px] bg-base-200 p-4 text-base-content">
	<div>
		<p>
			Entwickelt von <a
				class="link"
				target="_blank"
				rel="noreferrer"
				href="https://lo-ng.netlify.app/">Long Nguyen</a
			>, LeibnizWissenschaftsCampus SOEP RegioHub, Universität Bielefeld (<a
				class="link"
				target="_blank"
				rel="noreferrer"
				href="https://github.com/long39ng/soep-regiohub-dataexplorer/"
				>Quellcode</a
			>). Veröffentlicht unter der Lizenz
			<a
				class="link"
				target="_blank"
				rel="noreferrer"
				href="https://creativecommons.org/licenses/by/4.0/legalcode"
				>CC-by 4.0</a
			>.
		</p>
	</div>
</footer>
