import type { registerMap } from "echarts";
import mapNuts1 from "./assets/map-nuts1.json";
import mapNuts3 from "./assets/map-nuts3.json";

type GeoJson = Parameters<typeof registerMap>[1];

type NamedGeoJson = GeoJson & {
	name: string;
};

export const mapGeo = {
	nuts1: mapNuts1 as NamedGeoJson,
	nuts3: mapNuts3 as NamedGeoJson,
};
