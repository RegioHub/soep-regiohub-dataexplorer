<!-- Adapted from https://github.com/bherbruck/svelte-echarts -->

<script lang="ts">
	import { createEventDispatcher } from "svelte";
	import type { Action } from "svelte/action";
	import { init, type EChartsOption, type EChartsType } from "echarts";
	import type { EChartSelectchangedEvent } from "./utils";

	export let instance: EChartsType;
	export let option: EChartsOption = {
		fontFamily:
			'ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica Neue, Arial, Noto Sans, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", Segoe UI Symbol, "Noto Color Emoji"',
	};
	export let replaceMerge: ("xAxis" | "yAxis" | "series")[] = [];

	const dispatch = createEventDispatcher();

	const chart: Action<HTMLDivElement, EChartsOption> = (node, option) => {
		instance = init(node);
		instance.setOption(option!);

		instance.on("selectchanged", (event) => {
			const { selected, fromActionPayload } = event as EChartSelectchangedEvent;
			dispatch(
				"selectchanged",
				selected.length === 0 ? { type: "unselectAll" } : fromActionPayload
			);
		});

		return {
			destroy(): void {
				instance.dispose();
			},
			update(newOption: EChartsOption): void {
				instance.setOption({ ...option, ...newOption }, { replaceMerge });
			},
		};
	};
</script>

<svelte:window on:resize={() => instance.resize()} />

<div class="h-full w-full" use:chart={option} />
