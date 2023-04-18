<!-- Adapted from https://github.com/bherbruck/svelte-echarts -->

<script lang="ts">
	import { init, type EChartsOption, type EChartsType } from "echarts";

	export let instance: EChartsType | undefined = undefined;
	export let option: EChartsOption;

	export function chart(
		node: HTMLElement,
		option: EChartsOption
	): { destroy(): void; update(newOption: EChartsOption): void } {
		instance = init(node);
		instance.setOption(option);

		function handleResize(): void {
			instance?.resize();
		}
		window.addEventListener("resize", handleResize);

		return {
			destroy() {
				instance?.dispose();
				window.removeEventListener("resize", handleResize);
			},
			update(newOption: EChartsOption) {
				instance?.setOption({ ...option, ...newOption });
			},
		};
	}
</script>

<div class="h-full w-full" use:chart={option} />
