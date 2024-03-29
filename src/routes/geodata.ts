import type { registerMap } from "echarts";
import mapNuts1 from "./assets/map-nuts1.json";
import mapNuts3 from "./assets/map-nuts3.json";
import { objMap } from "./utils";

type GeoJson = typeof mapNuts1 & Parameters<typeof registerMap>[1];

export const mapGeo = {
	nuts1: mapNuts1 as GeoJson,
	nuts3: mapNuts3 as GeoJson,
};

export const regionNames = objMap(mapGeo, (level) =>
	level.features.map((feat) => feat.properties.name)
);
