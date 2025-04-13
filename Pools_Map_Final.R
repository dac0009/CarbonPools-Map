library(tidyverse)
library(leaflet)
library(sf)
library(htmltools)
library(rnaturalearth)
library(rnaturalearthdata)

# Load data
data <- read.csv("data/Clean_Carbon_Data.csv")

# Filter for 2023, individual forests, and exclude "Total Forest Ecosystem"
plot_data <- data %>%
  filter(
    Year == 2023,
    ForestLabel == "Forest",
    Pool != "Total Forest Ecosystem"
  ) %>%
  select(Forest, Pool, DensityTonnesHectare)

# Assign approximate coordinates (latitude, longitude) for each forest, including Alaska
forest_coords <- tribble(
  ~Forest, ~Longitude, ~Latitude,
  "Olympic", -124.0, 47.5,
  "Mt. Baker-Snoqualmie", -121.8, 48.0,
  "Gifford Pinchot", -121.7, 46.0,
  "Mt. Hood", -121.6, 45.4,
  "Columbia River Gorge National Scenic Area", -121.5, 45.7,
  "Willamette", -122.0, 44.5,
  "Siuslaw", -123.5, 44.0,
  "Umpqua", -122.5, 43.5,
  "Rogue River-Siskiyou", -122.8, 42.5,
  "Deschutes", -121.5, 44.0,
  "Ochoco", -120.5, 44.5,
  "Fremont-Winema", -120.8, 42.5,
  "Malheur", -118.5, 44.0,
  "Umatilla", -118.2, 45.5,
  "Wallowa-Whitman", -117.5, 45.0,
  "Colville", -117.9, 48.5,
  "Okanogan-Wenatchee", -120.0, 47.5,
  "Idaho Panhandle", -116.5, 47.5,
  "Kootenai", -115.8, 48.5,
  "Nez Perce-Clearwater", -115.0, 46.0,
  "Boise", -115.5, 43.5,
  "Payette", -115.3, 44.5,
  "Sawtooth", -114.8, 43.5,
  "Salmon-Challis", -114.0, 44.5,
  "Caribou-Targhee", -112.0, 43.0,
  # Adding Alaska's national forests (Tongass and Chugach)
  "Tongass", -135.0, 58.0,  # Approximate center of Tongass (Southeast Alaska)
  "Chugach", -150.0, 61.0   # Approximate center of Chugach (Southcentral Alaska)
)

# Join coordinates and prepare data
plot_data <- plot_data %>%
  left_join(forest_coords, by = "Forest") %>%
  filter(!is.na(Longitude))

# Summarize total carbon density per forest for marker color
plot_data_summary <- plot_data %>%
  group_by(Forest, Longitude, Latitude) %>%
  summarize(TotalDensity = sum(DensityTonnesHectare, na.rm = TRUE), .groups = "drop")

# Prepare popup data: create a table of carbon pools for each forest
popup_data <- plot_data %>%
  group_by(Forest) %>%
  summarize(
    PopupText = paste(
      "<b>", Forest[1], "</b><br>",
      "<table border='1' style='border-collapse: collapse;'>",
      "<tr><th>Carbon Pool</th><th>Density (tonnes/ha)</th></tr>",
      paste(
        "<tr><td>", Pool, "</td><td>", round(DensityTonnesHectare, 2), "</td></tr>",
        collapse = ""
      ),
      "</table>"
    ),
    .groups = "drop"
  )

# Join popup text with summary data
plot_data_summary <- plot_data_summary %>%
  left_join(popup_data, by = "Forest")

# Get base map for Washington, Oregon, Idaho, and Alaska
states <- ne_states(country = "United States of America", returnclass = "sf") %>%
  filter(name %in% c("Washington", "Oregon", "Idaho", "Alaska"))

# Simulate Cascade Range as a polygon (approximate)
cascade_range <- st_polygon(list(
  matrix(c(
    -122.0, 48.0,  # Top-left
    -121.0, 48.0,  # Top-right
    -121.0, 42.0,  # Bottom-right
    -122.0, 42.0,  # Bottom-left
    -122.0, 48.0   # Close polygon
  ), ncol = 2, byrow = TRUE)
)) %>%
  st_sfc(crs = 4326) %>%
  st_sf()

# Create a color palette for total carbon density
pal <- colorNumeric(palette = "YlOrRd", domain = plot_data_summary$TotalDensity)

# Create the interactive map
m <- leaflet() %>%
  # Add terrain tiles
  addProviderTiles(providers$Esri.WorldShadedRelief) %>%
  # Adjust the map view to include both Alaska and the Pacific Northwest
  fitBounds(
    lng1 = -150, lat1 = 40,  # Southwest corner (covers Pacific Northwest)
    lng2 = -112, lat2 = 65   # Northeast corner (covers Alaska)
  ) %>%
  # Add state boundaries
  addPolygons(
    data = states,
    fillColor = "white",
    fillOpacity = 0.5,
    color = "black",
    weight = 1
  ) %>%
  # Highlight Cascade Range
  addPolygons(
    data = cascade_range,
    fillColor = "gray50",
    fillOpacity = 0.3,
    color = NA
  ) %>%
  # Add markers for each forest
  addCircleMarkers(
    data = plot_data_summary,
    lng = ~Longitude,
    lat = ~Latitude,
    radius = 8,
    color = ~pal(TotalDensity),
    fillOpacity = 0.8,
    popup = ~PopupText,
    label = ~Forest
  ) %>%
  # Add a legend for total carbon density
  addLegend(
    position = "bottomright",
    pal = pal,
    values = plot_data_summary$TotalDensity,
    title = "Total Carbon Density (tonnes/ha)",
    opacity = 0.8
  )

# Display the map
m

# Save as an HTML file
htmlwidgets::saveWidget(m, "Carbon_Density_Interactive_Map_With_Alaska.html")
###################################################################
data <- read.csv("data/Clean_Carbon_Data.csv")
#Load both datasets
alaska_data <- data %>%
  filter(RegionNumber == 10)
pnw_data <- data %>%
  filter(RegionNumber == 6)

# Combine using bind_rows (assumes same column structure)
combined_data <- bind_rows(alaska_data, pnw_data)

# List Idaho forests for filtering
idaho_forests <- c(
  "Idaho Panhandle", "Coeur d'Alene", "Kaniksu", "St. Joe",  # Region 1
  "Kootenai", "Nez Perce-Clearwater",
  "Boise", "Caribou-Targhee", "Payette", "Salmon-Challis", "Sawtooth")  # Region 4

# Filter for Idaho forests in Regions 1 and 4
idaho_data <- data %>%
  filter(
    (RegionNumber %in% c(1, 4)) &
      (Forest %in% idaho_forests | grepl("Idaho|Nez Perce|Clearwater", Forest, ignore.case = TRUE))
  )
# Combine Alaska, Pacific Northwest, and Idaho data
combined_data <- bind_rows(alaska_data, pnw_data, idaho_data)

# Verify the combined dataset
print(head(combined_data))
cat("Unique forests:", unique(combined_data$Forest), "\n")
cat("Unique regions:", unique(combined_data$RegionNumber), "\n")
#######
library(tidyverse)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(ggspatial)
install.packages("ggforce")
library(ggforce)  # For pie charts

# Load data
data <- read.csv("data/Clean_Carbon_Data.csv")

# Filter for Regions 1, 4, 6 (exclude Alaska), 2023, individual forests, and relevant pools
plot_data <- data %>%
  filter(
    RegionNumber %in% c(1, 4, 6),
    Year == 2023,
    ForestLabel == "Forest",
    Pool != "Total Forest Ecosystem"
  ) %>%
  select(Forest, Pool, DensityTonnesHectare)

# Assign approximate coordinates (latitude, longitude) for each forest
forest_coords <- tribble(
  ~Forest, ~Longitude, ~Latitude,
  "Olympic", -124.0, 47.5,
  "Mt. Baker-Snoqualmie", -121.8, 48.0,
  "Gifford Pinchot", -121.7, 46.0,
  "Mt. Hood", -121.6, 45.4,
  "Columbia River Gorge National Scenic Area", -121.5, 45.7,
  "Willamette", -122.0, 44.5,
  "Siuslaw", -123.5, 44.0,
  "Umpqua", -122.5, 43.5,
  "Rogue River-Siskiyou", -122.8, 42.5,
  "Deschutes", -121.5, 44.0,
  "Ochoco", -120.5, 44.5,
  "Fremont-Winema", -120.8, 42.5,
  "Malheur", -118.5, 44.0,
  "Umatilla", -118.2, 45.5,
  "Wallowa-Whitman", -117.5, 45.0,
  "Colville", -117.9, 48.5,
  "Okanogan-Wenatchee", -120.0, 47.5,
  "Idaho Panhandle", -116.5, 47.5,
  "Kootenai", -115.8, 48.5,
  "Nez Perce-Clearwater", -115.0, 46.0,
  "Boise", -115.5, 43.5,
  "Payette", -115.3, 44.5,
  "Sawtooth", -114.8, 43.5,
  "Salmon-Challis", -114.0, 44.5,
  "Caribou-Targhee", -112.0, 43.0
)

# Join coordinates and summarize total carbon density per forest
plot_data_summary <- plot_data %>%
  left_join(forest_coords, by = "Forest") %>%
  filter(!is.na(Longitude)) %>%
  group_by(Forest, Longitude, Latitude) %>%
  summarize(TotalDensity = sum(DensityTonnesHectare, na.rm = TRUE), .groups = "drop")

# Prepare data for pie charts: calculate cumulative proportions for each pool
plot_data_pie <- plot_data %>%
  left_join(forest_coords, by = "Forest") %>%
  filter(!is.na(Longitude)) %>%
  group_by(Forest, Longitude, Latitude) %>%
  mutate(
    Total = sum(DensityTonnesHectare, na.rm = TRUE),
    Prop = DensityTonnesHectare / Total,
    CumProp = cumsum(Prop),
    Start = lag(CumProp, default = 0),
    End = CumProp,
    StartAngle = Start * 2 * pi,
    EndAngle = End * 2 * pi
  ) %>%
  ungroup()

# Get base map for Washington, Oregon, Idaho
states <- ne_states(country = "United States of America", returnclass = "sf") %>%
  filter(name %in% c("Washington", "Oregon", "Idaho"))

# Simulate Cascade Range as a polygon (approximate)
cascade_range <- st_polygon(list(
  matrix(c(
    -122.0, 48.0,  # Top-left
    -121.0, 48.0,  # Top-right
    -121.0, 42.0,  # Bottom-right
    -122.0, 42.0,  # Bottom-left
    -122.0, 48.0   # Close polygon
  ), ncol = 2, byrow = TRUE)
)) %>%
  st_sfc(crs = 4326) %>%
  st_sf()

# Create the map
p <- ggplot() +
  # Base map (states)
  geom_sf(data = states, fill = "white", color = "black") +
  # Highlight Cascade Range
  geom_sf(data = cascade_range, fill = "gray50", alpha = 0.3, color = NA) +
  # Add points for forests, sized by total carbon density
  geom_point(
    data = plot_data_summary,
    aes(x = Longitude, y = Latitude, size = TotalDensity),
    color = "black", alpha = 0.7
  ) +
  # Add pie charts for carbon pool breakdown
  geom_arc_bar(
    data = plot_data_pie,
    aes(x0 = Longitude, y0 = Latitude, r0 = 0, r = 0.5, start = StartAngle, end = EndAngle, fill = Pool),
    color = "white", linewidth = 0.2
  ) +
  # Color palette for pools
  scale_fill_manual(
    values = c(
      "Aboveground Live Tree" = "#1b9e77",
      "Belowground Live Tree" = "#d95f02",
      "Understory" = "#7570b3",
      "Standing Dead" = "#e7298a",
      "Downed Dead Wood" = "#66a61e",
      "Litter" = "#e6ab02",
      "Soil Organic Carbon" = "#a6761d"
    ),
    name = "Carbon Pool"
  ) +
  # Scale size for points
  scale_size_continuous(name = "Total Carbon Density (tonnes/ha)", range = c(2, 10)) +
  # Add scale bar and north arrow
  annotation_scale(location = "bl", width_hint = 0.5) +
  annotation_north_arrow(location = "tl", which_north = "true", 
                         style = north_arrow_fancy_orienteering) +
  # Theme adjustments
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "right",
    panel.grid = element_blank(),
    axis.text = element_blank(),
    axis.title = element_blank(),
    plot.background = element_rect(fill = "white", color = NA)
  ) +
  labs(
    title = "Carbon Density Across National Forests: West to East Journey",
    subtitle = "Proportional Pies Show Carbon Pool Breakdown, 2023",
    caption = "Data for 2023, excluding aggregate regions."
  )

# Display the plot
print(p)

# Save as a high-resolution PNG
ggsave("plots/Carbon_Density_Map_West_to_East.png", p, width = 10, height = 8, dpi = 300)