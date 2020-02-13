library(rgdal)
library(rgeos)
library(plyr)
library(cartogram)
library(tmap)

# Set working directory
setwd('..')

# ********************************************************************************************
# Load map shapefile from Natural Earth (https://www.naturalearthdata.com/downloads/110m-cultural-vectors/)
# ********************************************************************************************

# Load shapefile
shp <- readOGR("ne_110m_admin_0_countries/ne_110m_admin_0_countries.shp")

# Remove Antarctica from the map
shp <- subset(shp, ADMIN != "Antarctica")

# Change projection to Robinson
shp <- spTransform(shp, CRS("+proj=robin"))

# Check whether shape is valid: some warnings (will proceed with caution)
rgeos::gIsValid(shp)

# Plot the map
png(file = "world.png", width=800)
plot(shp)
dev.off()


# ********************************************************************************************
# World Population Prospects (WPP), 2019 Revision (https://population.un.org/wpp/)
# data on population in 2020 and 2100 forecasts under different variants
# ********************************************************************************************

# Load data excerpt
wpp = read.csv("WPP2019_2020_2100.csv")

# Rename column with countries as ADMIN to merge later with map attributes data
colnames(wpp)[1] <- "ADMIN"

# Convert data to millions (it was originally in thousands)
wpp$PopTotal <- wpp$PopTotal / 1000

# Reshape into a wide format to have one country per row
# and in columns population data for 2020 and 2100 under different variants
wpp_wide <- reshape(wpp,
    timevar = "Time",
    idvar = c("ADMIN", "Variant"),
    direction = "wide")

wpp_wide <- reshape(wpp_wide,
    timevar = "Variant",
    idvar = "ADMIN",
    direction = "wide")

# Rename specific spelling of some country names to match with map attributes data
wpp_wide[["ADMIN"]] <- as.character(wpp_wide[["ADMIN"]])
wpp_wide$ADMIN[wpp_wide$ADMIN == "Bolivia (Plurinational State of)"] <- "Bolivia"
wpp_wide$ADMIN[wpp_wide$ADMIN == "Brunei Darussalam"] <- "Brunei"
wpp_wide$ADMIN[wpp_wide$ADMIN == "Timor-Leste"] <- "East Timor"
wpp_wide$ADMIN[wpp_wide$ADMIN == "Eswatini"] <- "eSwatini"
wpp_wide$ADMIN[wpp_wide$ADMIN == "Falkland Islands (Malvinas)"] <- "Falkland Islands"
wpp_wide$ADMIN[wpp_wide$ADMIN == "Iran (Islamic Republic of)"] <- "Iran"
wpp_wide$ADMIN[wpp_wide$ADMIN == "CÃ´te d'Ivoire"] <- "Ivory Coast"
wpp_wide$ADMIN[wpp_wide$ADMIN == "Lao People's Democratic Republic"] <- "Laos"
wpp_wide$ADMIN[wpp_wide$ADMIN == "North Macedonia"] <- "Macedonia"
wpp_wide$ADMIN[wpp_wide$ADMIN == "Republic of Moldova"] <- "Moldova"
wpp_wide$ADMIN[wpp_wide$ADMIN == "Dem. People's Republic of Korea"] <- "North Korea"
wpp_wide$ADMIN[wpp_wide$ADMIN == "State of Palestine"] <- "Palestine"
wpp_wide$ADMIN[wpp_wide$ADMIN == "Serbia"] <- "Republic of Serbia"
wpp_wide$ADMIN[wpp_wide$ADMIN == "Congo"] <- "Republic of the Congo"
wpp_wide$ADMIN[wpp_wide$ADMIN == "Russian Federation"] <- "Russia"
wpp_wide$ADMIN[wpp_wide$ADMIN == "Republic of Korea"] <- "South Korea"
wpp_wide$ADMIN[wpp_wide$ADMIN == "Syrian Arab Republic"] <- "Syria"
wpp_wide$ADMIN[wpp_wide$ADMIN == "China, Taiwan Province of China"] <- "Taiwan"
wpp_wide$ADMIN[wpp_wide$ADMIN == "Bahamas"] <- "The Bahamas"
wpp_wide$ADMIN[wpp_wide$ADMIN == "Venezuela (Bolivarian Republic of)"] <- "Venezuela"
wpp_wide$ADMIN[wpp_wide$ADMIN == "Viet Nam"] <- "Vietnam"

# Merge WPP with map attributes data, make sure to preserve the order (use join from plyr instead of merge)
# and keep all rows in the map attributes data (type = "left")
shp@data <- join(shp@data, wpp_wide, by="ADMIN", type = "left")

# Check which countries were not merged (then population data in 2020 will be missing)
not_merged <- subset(shp@data, is.na(shp@data$PopTotal.2020.Medium), select=c("ADMIN", "PopTotal.2020.Medium"))
# For these territories data on population from WPP is not available:
print(not_merged$ADMIN)
# French Southern and Antarctic Lands
# Kosovo
# Northern Cyprus
# Somaliland

# For territories where WPP data is not available, will use as a constant the POP_EST data provided by Natural Earth
# Transform POP_EST from factor to numeric, convert to millions
shp@data[["POP_EST"]] <- as.numeric(as.character(shp@data[["POP_EST"]])) / 1000000
for (i in colnames(wpp_wide[-1])) {
    for (j in as.character(not_merged$ADMIN)) {
        shp@data[[i]][shp@data$ADMIN == j] <- shp@data[["POP_EST"]][shp@data$ADMIN == j]
    }
}


# ********************************************************************************************
# Create cartograms and plot
# ********************************************************************************************

# Regular map, color based on 2020 population
png(file = "world_2020.png", width=800)
tm_shape(shp) +
    tm_polygons("PopTotal.2020.Medium", title = "Population in 2020,\n(Millions)", style = "fixed", breaks = c(0, 50, 100, 250, 500, 1000, 1250, 1500, 2000, 2500)) +
    tm_layout(frame = FALSE, legend.position = c("left", "bottom"))
dev.off()

# Cartogram, based on 2020 population
shp_2020 <- cartogram_cont(shp, "PopTotal.2020.Medium", itermax = 3)
png(file = "cartogram_2020.png", width=800)
tm_shape(shp_2020) +
    tm_polygons("PopTotal.2020.Medium", title = "Population in 2020,\n(Millions)", style = "fixed", breaks = c(0, 50, 100, 250, 500, 1000, 1250, 1500, 2000, 2500)) +
    tm_layout(frame = FALSE, legend.position = c("left", "bottom"))
dev.off()

# Cartogram, based on 2100 population, Medium variant
shp_2100_medium <- cartogram_cont(shp, "PopTotal.2100.Medium", itermax = 3)
png(file = "cartogram_2100_medium.png", width=800)
tm_shape(shp_2100_medium) +
    tm_polygons("PopTotal.2100.Medium", title = "Population in 2100,\nMedium variant (Millions)", style = "fixed", breaks = c(0, 50, 100, 250, 500, 1000, 1250, 1500, 2000, 2500)) +
    tm_layout(frame = FALSE, legend.position = c("left", "bottom"))
dev.off()

# Cartogram, based on 2100 population, High variant
shp_2100_high <- cartogram_cont(shp, "PopTotal.2100.High", itermax = 3)
png(file = "cartogram_2100_high.png", width=800)
tm_shape(shp_2100_high) +
    tm_polygons("PopTotal.2100.High", title = "Population in 2100,\nHigh variant (Millions)", style = "fixed", breaks = c(0, 50, 100, 250, 500, 1000, 1250, 1500, 2000, 2500)) +
    tm_layout(frame = FALSE, legend.position = c("left", "bottom"))
dev.off()

# Cartogram, based on 2100 population, Low variant
shp_2100_low <- cartogram_cont(shp, "PopTotal.2100.Low", itermax = 3)
png(file = "cartogram_2100_low.png", width=800)
tm_shape(shp_2100_low) +
    tm_polygons("PopTotal.2100.Low", title = "Population in 2100,\nLow variant (Millions)", style = "fixed", breaks = c(0, 50, 100, 250, 500, 1000, 1250, 1500, 2000, 2500)) +
    tm_layout(frame = FALSE, legend.position = c("left", "bottom"))
dev.off()
