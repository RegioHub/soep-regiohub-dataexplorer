library(dplyr)
library(purrr)
library(sf)

de_nuts1 <- giscoR::gisco_get_nuts(country = "DE", nuts_level = 1, resolution = "10") |>
  select(name = NAME_LATN, nuts1 = NUTS_ID)

de_nuts3 <- giscoR::gisco_get_nuts(country = "DE", nuts_level = 3, resolution = "10") |>
  select(name = NAME_LATN, nuts3 = NUTS_ID) |>
  mutate(nuts1 = substr(nuts3, 1, 3))

fake_data_nuts3 <- de_nuts3 |>
  select(name, nuts3, nuts1) |>
  st_drop_geometry() |>
  slice(rep(row_number(), 4)) |>
  with_groups(c(name, nuts3), mutate, year = row_number() + 2015L) |>
  reduce(
    paste0("v", 1:4),
    \(df, col) mutate(df, !!col := rnorm(n())),
    .init = _
  )

fake_data_nuts1 <- fake_data_nuts3 |>
  with_groups(c(nuts1, year), summarise, across(v1:v4, mean)) |>
  left_join(st_drop_geometry(de_nuts1), by = "nuts1") |>
  relocate(name)

iwalk(
  mget(c("de_nuts1", "de_nuts3", "fake_data_nuts1", "fake_data_nuts3")),
  \(x, i) saveRDS(x, paste0("data/", i, ".RDS"), compress = FALSE)
)
