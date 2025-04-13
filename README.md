# Overview
This project creates an interactive map visualizing carbon density across U.S. national forests in all 50 states, including Alaska and Hawaii, for the year 2023. Built using R and the leaflet package, the map allows users to explore carbon pools (e.g., Aboveground Live Tree, Soil Organic Carbon) for each national forest. The data is sourced from Clean_Carbon_Data.csv, which contains carbon density estimates (tonnes/ha) across all 10 U.S. Forest Service regions.

Key Features
Clickable Markers: Each national forest is represented by a marker, colored by total carbon density (tonnes/ha). Clicking a marker displays a popup with a detailed table of carbon pools (e.g., Aboveground Live Tree: 50.23 tonnes/ha).
Nationwide Coverage: Includes forests across all 10 U.S. Forest Service regions, from the Tongass in Alaska to the Ocala in Florida.
Layer Control: Toggle visibility of forests by region (e.g., Region 1, Region 5) to focus on specific areas and reduce clutter.
Marker Clustering: Clusters markers at high zoom levels for better usability when viewing the entire U.S.
Geographical Context: Highlights the Cascade Range with a shaded polygon, includes state boundaries, and uses a terrain background (Esri.WorldShadedRelief) for visual appeal.
Exportable Output: The map is saved as an HTML file (Carbon_Density_Interactive_Map_All_States.html), which can be viewed in a browser or hosted online.
Prerequisites
To run this project, you’ll need the following:

R: Version 4.0 or higher (download from CRAN).
RStudio (optional but recommended): Download from RStudio.
R Packages:
tidyverse: For data manipulation and visualization.
leaflet: For creating the interactive map.
sf: For handling spatial data.
htmltools: For formatting popups.
rnaturalearth and rnaturalearthdata: For base maps of U.S. states.
Install the required packages in R:

R

Collapse

Wrap

Copy
install.packages(c("tidyverse", "leaflet", "sf", "htmltools", "rnaturalearth", "rnaturalearthdata"))
Installation
Clone the Repository:
Clone this repository to your local machine using:

bash

Collapse

Wrap

Copy
git clone https://github.com/your-username/your-repo-name.git
Replace your-username and your-repo-name with your GitHub username and repository name.

Set Working Directory:
In R or RStudio, set your working directory to the cloned repository folder:

R

Collapse

Wrap

Copy
setwd("path/to/your-repo-name")
Prepare the Data:
Ensure the dataset data/Clean_Carbon_Data.csv is in the data/ directory. This file should contain columns such as RegionNumber, Forest, Pool, DensityTonnesHectare, Year, and ForestLabel. The script expects data for 2023 across all U.S. Forest Service regions (1–10).

If you don’t have this dataset, you’ll need to source carbon pool data from the U.S. Forest Service’s Forest Inventory and Analysis (FIA) program or similar sources.

Usage
Run the Script:
Open the R script (script.R or the name of your main script) in R or RStudio and run it. The script will:

Load and process the carbon density data.
Assign approximate coordinates to each national forest.
Generate an interactive map with clickable markers, layer controls, and clustering.
R

Collapse

Wrap

Copy
source("script.R")
Interact with the Map:

The map will open in your default browser or RStudio’s viewer.
Zoom and Pan: Explore different regions of the U.S.
Click Markers: Click on a marker to see a popup with the forest’s name and a table of carbon pools (e.g., Aboveground Live Tree, Soil Organic Carbon) with their densities.
Toggle Layers: Use the layer control to show/hide forests by region (e.g., show only Region 5 forests in California).
Clustering: Zoom out to see markers cluster together; zoom in to view individual forests.
Saved Output:
The map is automatically saved as Carbon_Density_Interactive_Map_All_States.html in the repository’s root directory. You can open this file in any web browser or host it online (e.g., on GitHub Pages) to share with others.

Data
Source: The map uses Clean_Carbon_Data.csv, which contains carbon density data (tonnes/ha) for U.S. national forests in 2023.
Structure: The dataset includes columns like:
RegionNumber: U.S. Forest Service region (1–10).
Forest: Name of the national forest.
Pool: Carbon pool (e.g., Aboveground Live Tree, Soil Organic Carbon).
DensityTonnesHectare: Carbon density in tonnes per hectare.
Year: Year of the data (filtered for 2023).
ForestLabel: Indicates whether the entry is for an individual forest.
Coordinates: Approximate latitude/longitude coordinates for each forest are hardcoded in the script. For more precision, replace these with exact centroids from USDA shapefiles or the FIA database.
Customization
You can customize the map by modifying the script:

Marker Size: Adjust the radius in addCircleMarkers (e.g., radius = 10) or scale by total density (radius = ~sqrt(TotalDensity) * 0.1).
Colors: Change the color palette for total carbon density by modifying the pal object (e.g., use "Viridis" instead of "YlOrRd").
Additional Features: Highlight other geographical features (e.g., Rocky Mountains, Appalachians) by adding polygons, similar to the Cascade Range. You’ll need shapefiles for these regions.
Coordinates Accuracy: Replace the approximate coordinates in forest_coords with precise centroids from USDA shapefiles for better accuracy.
Limitations
Data Completeness: The map assumes Clean_Carbon_Data.csv includes data for all U.S. Forest Service regions (1–10). If data is missing for some regions, those forests won’t appear. You can source additional data from the FIA program if needed.
Coordinates: The coordinates provided are approximate. For precise mapping, use centroids from USDA shapefiles.
Projection: Leaflet uses the Web Mercator projection, which distorts Alaska and Hawaii. This is acceptable for an interactive map but may not be ideal for precise spatial analysis.
Clutter: With forests across all 50 states, the map can feel cluttered at a zoomed-out level. Marker clustering and layer controls help mitigate this.
Contributing
Contributions are welcome! If you’d like to improve the map, add more data, or enhance features, feel free to fork the repository and submit a pull request. Some ideas for contributions:

Add precise coordinates for all forests using USDA shapefiles.
Include additional geographical features (e.g., Rocky Mountains, Appalachians).
Integrate more recent or detailed carbon data from the FIA program.
License
This project is licensed under the MIT License. See the  file for details.

Acknowledgments
The leaflet package for enabling interactive mapping in R.
The rnaturalearth package for providing U.S. state boundaries.
The U.S. Forest Service’s Forest Inventory and Analysis (FIA) program for carbon data inspiration.
Contact
For questions or feedback, feel free to open an issue on GitHub or contact the repository owner at your-email@example.com.

Notes for You
File Placement: Save this as README.md in the root directory of your GitHub repository. GitHub will automatically render it on the repository’s main page.
Customization: Replace placeholders like your-username, your-repo-name, and your-email@example.com with your actual GitHub username, repository name, and email.
License: The README mentions an MIT License, but you can change this to your preferred license (e.g., GPL, Apache). If you don’t have a LICENSE file, you’ll need to add one to the repository.
Script Name: I assumed your main script is named script.R. If it has a different name, update the "Usage" section accordingly.
Data Directory: The README assumes Clean_Carbon_Data.csv is in a data/ subdirectory. Adjust the paths if your directory structure is different.
