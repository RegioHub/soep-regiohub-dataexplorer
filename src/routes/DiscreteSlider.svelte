<script lang="ts">
	import RangeSlider from "svelte-range-slider-pips";
	import type { Stringable } from "./utils";

	export let options: Stringable[];
	export let selected = [0];
</script>

<div class="sliderContainer">
	<RangeSlider
		min={0}
		max={options.length - 1}
		step={1}
		pips
		first="label"
		last="label"
		formatter={(i) => options[i].toString()}
		float
		springValues={{ stiffness: 1, damping: 1 }}
		bind:values={selected}
	/>
</div>

<style lang="postcss">
	:global(.sliderContainer > .rangeSlider) {
		--slider: hsl(var(--b3));
		--handle-inactive: hsl(var(--n));
		--handle: hsl(var(--n));
		--handle-focus: hsl(var(--nf));
		--float-text: hsl(var(--nc));

		--pip: hsl(var(--bc));
		--pip-active: hsl(var(--bc));
		--pip-hover: hsl(var(--bc));
	}
	:global(.sliderContainer > .rangeSlider.pip-labels) {
		@apply text-sm;
	}
	:global(.sliderContainer > .rangeSlider > .rangeHandle > .rangeFloat) {
		@apply top-[-0.2rem] text-sm font-semibold opacity-100;
	}
</style>
