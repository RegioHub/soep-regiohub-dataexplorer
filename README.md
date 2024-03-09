# SOEP RegioHub DataExplorer

👉🗺️📊 https://regiohub.github.io/soep-regiohub-dataexplorer/

Web application for interactive exploration of data at SOEP RegioHub

![Screenshot of the app interface](https://user-images.githubusercontent.com/25417022/234571134-0f4dc43d-5d8d-4218-92eb-2d12cd0a7c0c.png)

## Development

### Prerequisites

- Node.js

### Setup

1. Clone the repository
2. Install dependencies: `npm install`

### File structure

(See also SvelteKit documentation: https://kit.svelte.dev/docs/routing)

- `src/routes/`:
  - `+page.svelte`: Home page
  - `+layout.svelte`: Layout for all pages (here: only the home page)
  - `*.svelte` (Pascal case): Components used in the home page
    - `LineChart.svelte`, `Map.svelte`: Visualization components, depend on `Echarts.svelte`, which is a wrapper for the ECharts library (docs: https://echarts.apache.org/en/api.html, https://echarts.apache.org/en/option.html)
    - `DiscreteSlider.svelte`: Slider for selecting year
  - `*.ts`: Server-side functions (e.g. for loading data)
  - `metadata.json`: Metadata for the visualized variables
  - `assets/`: Static files (data, images)

### Testing and deployment

- Start development server and open browser

```bash
npm run dev -- --open
```

- Build for production

```bash
npm run build
```

- Serve production build locally

```bash
npm run preview
```

- Deploy to GitHub Pages

```bash
npm run deploy
```
