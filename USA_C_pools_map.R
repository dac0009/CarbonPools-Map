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

# Assign approximate coordinates (latitude, longitude) for national forests across all 50 states
# Note: This is a simplified list; coordinates are approximate centroids
forest_coords <- tribble(
  ~Forest, ~Longitude, ~Latitude,
  # Region 1: Northern Region (MT, ID, ND, SD)
  "Idaho Panhandle", -116.5, 47.5,
  "Kootenai", -115.8, 48.5,
  "Nez Perce-Clearwater", -115.0, 46.0,
  "Flathead", -114.0, 48.0,
  "Lolo", -114.5, 46.5,
  "Helena-Lewis and Clark", -112.5, 46.5,
  "Beaverhead-Deerlodge", -112.8, 45.5,
  "Custer Gallatin", -110.0, 45.0,
  "Dakota Prairie Grasslands", -103.5, 46.0,
  # Region 2: Rocky Mountain Region (CO, WY, SD, NE, KS)
  "Arapaho-Roosevelt", -105.5, 40.0,
  "Grand Mesa, Uncompahgre, and Gunnison", -107.0, 38.5,
  "Pike-San Isabel", -105.0, 38.5,
  "Rio Grande", -106.0, 37.5,
  "San Juan", -107.5, 37.5,
  "Bighorn", -107.0, 44.5,
  "Shoshone", -109.5, 44.0,
  "Medicine Bow-Routt", -106.0, 41.0,
  "Black Hills", -103.5, 44.0,
  "Nebraska", -103.0, 42.5,
  # Region 3: Southwestern Region (AZ, NM)
  "Apache-Sitgreaves", -109.5, 34.0,
  "Coconino", -111.5, 35.0,
  "Coronado", -110.5, 32.5,
  "Kaibab", -112.0, 36.5,
  "Prescott", -112.5, 34.5,
  "Tonto", -111.0, 33.8,
  "Cibola", -106.5, 34.5,
  "Gila", -108.5, 33.5,
  "Lincoln", -105.5, 33.5,
  "Santa Fe", -105.8, 35.5,
  "Carson", -106.0, 36.0,
  # Region 4: Intermountain Region (UT, NV, ID, WY)
  "Boise", -115.5, 43.5,
  "Payette", -115.3, 44.5,
  "Sawtooth", -114.8, 43.5,
  "Salmon-Challis", -114.0, 44.5,
  "Caribou-Targhee", -112.0, 43.0,
  "Ashley", -109.5, 40.5,
  "Dixie", -113.0, 37.5,
  "Fishlake", -112.0, 38.5,
  "Manti-La Sal", -111.5, 39.0,
  "Uinta-Wasatch-Cache", -111.0, 40.5,
  "Humboldt-Toiyabe", -116.0, 39.0,
  # Region 5: Pacific Southwest Region (CA)
  "Angeles", -118.0, 34.5,
  "Cleveland", -117.0, 33.0,
  "Eldorado", -120.5, 38.8,
  "Inyo", -118.0, 37.0,
  "Klamath", -123.0, 41.5,
  "Lassen", -121.0, 40.5,
  "Los Padres", -120.0, 34.5,
  "Mendocino", -123.0, 39.5,
  "Modoc", -120.5, 41.5,
  "Plumas", -121.0, 40.0,
  "San Bernardino", -117.0, 34.0,
  "Sequoia", -118.5, 36.5,
  "Shasta-Trinity", -122.5, 41.0,
  "Sierra", -119.5, 37.5,
  "Six Rivers", -123.5, 41.0,
  "Stanislaus", -120.0, 38.0,
  "Tahoe", -120.0, 39.0,
  # Region 6: Pacific Northwest Region (OR, WA)
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
  # Region 8: Southern Region (AL, AR, FL, GA, KY, LA, MS, NC, OK, SC, TN, TX, VA)
  "Chattahoochee-Oconee", -84.0, 34.5,
  "Cherokee", -84.5, 35.5,
  "Daniel Boone", -84.0, 37.5,
  "George Washington and Jefferson", -79.5, 38.5,
  "Nantahala-Pisgah", -82.5, 35.5,
  "Uwharrie", -80.0, 35.5,
  "Croatan", -77.0, 34.8,
  "Francis Marion and Sumter", -80.0, 33.5,
  "Apalachicola", -84.5, 30.0,
  "Conecuh", -86.5, 31.0,
  "Ocala", -81.5, 29.0,
  "Osceola", -81.0, 30.0,
  "Talladega", -86.0, 33.0,
  "Tuskegee", -85.5, 32.5,
  "Bankhead", -87.0, 34.0,
  "Ouachita", -93.5, 34.5,
  "Ozark-St. Francis", -93.0, 35.5,
  "Kisatchie", -92.5, 31.0,
  "Angelina", -94.5, 31.0,
  "Davy Crockett", -95.0, 31.5,
  "Sabine", -93.8, 31.5,
  "Sam Houston", -95.0, 30.5,
  # Region 9: Eastern Region (IL, IN, ME, MD, MA, MI, MN, MO, NH, NJ, NY, OH, PA, VT, WV, WI)
  "Allegheny", -79.0, 41.5,
  "Chequamegon-Nicolet", -89.0, 46.0,
  "Chippewa", -93.0, 47.5,
  "Hiawatha", -86.0, 46.5,
  "Huron-Manistee", -84.5, 44.0,
  "Ottawa", -88.5, 46.0,
  "Superior", -91.0, 47.5,
  "Green Mountain", -72.5, 44.0,
  "White Mountain", -71.5, 44.0,
  "Finger Lakes", -76.5, 42.5,
  "Monongahela", -80.0, 39.0,
  "Wayne", -82.0, 39.0,
  "Hoosier", -86.5, 39.0,
  "Shawnee", -89.0, 37.5,
  "Mark Twain", -91.0, 38.0,
  # Region 10: Alaska Region (AK)
  "Tongass", -135.0, 58.0,
  "Chugach", -150.0, 61.0
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

# Get base map for all 50 states
states <- ne_states(country = "United States of America", returnclass = "sf") %>%
  filter(admin == "United States of America")

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
  # Adjust the map view to include all 50 states, including Alaska and Hawaii
  fitBounds(
    lng1 = -180, lat1 = 20,   # Southwest corner (includes Hawaii)
    lng2 = -60,  lat2 = 72    # Northeast corner (includes Alaska)
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
htmlwidgets::saveWidget(m, "Carbon_Density_Interactive_Map_All_States.html")