#################################################################################### 
# 
# Created on Friday 24th January 2020 by Jacqueline Macmillan
# Code adapted from the tutorial "Interactive Maps with Linked Data and R"
# Url https://medium.swirrl.com/interactive-maps-with-linked-data-and-r-e977ea441cb
# Additional code adaptations inspired by "Open and plot shapefiles in R"
# Url https://www.r-graph-gallery.com/168-load-a-shape-file-into-r.html and
# "How to Make a Map with R in 10 (fairly) Easy Steps" 
# Url https://www.computerworld.com/article/3038270/create-maps-in-r-in-10-fairly-easy-steps.html
#
####################################################################################

# Load required packages to handle shapefiles, transform the data, import from
# Excel and create the map. 
library(SPARQL)
library(dplyr)
library(readxl)
library(leaflet)
library(rgdal)

# Download the Local Authority District (LAD) shapefile. 
# NOTE: I store it in a local folder. You have to change that if needed.
download.file("https://opendata.arcgis.com/datasets/fab4feab211c4899b602ecfbfbc420a3_4.zip?outSR=%7B%22wkid%22%3A27700%2C%22latestWkid%22%3A27700%7D",destfile="LAD.zip")

# Unzip this file. You can do it with R (as below), or clicking on the object you downloaded.
system("unzip C:/Users/Jac/Downloads/Local_Authority_Districts_December_2017_Ultra_Generalised_Clipped_Boundaries_in_United_Kingdom_WGS84.zip")

# Read in historical data and profile information from Excel files
excel2016 <- read_excel('C:/Users/Jac/Documents/BSc Computing Year 4 Pt2/Dissertation/RTest/Maps/SIMD2016.xlsx')
excel2012 <- read_excel('C:/Users/Jac/Documents/BSc Computing Year 4 Pt2/Dissertation/RTest/Maps/SIMD2012.xlsx')
excel2009 <- read_excel('C:/Users/Jac/Documents/BSc Computing Year 4 Pt2/Dissertation/RTest/Maps/SIMD2009.xlsx')
excel2006 <- read_excel('C:/Users/Jac/Documents/BSc Computing Year 4 Pt2/Dissertation/RTest/Maps/SIMD2006.xlsx')
excel2004 <- read_excel('C:/Users/Jac/Documents/BSc Computing Year 4 Pt2/Dissertation/RTest/Maps/SIMD2004.xlsx')
excelprof <- read_excel('C:/Users/Jac/Documents/BSc Computing Year 4 Pt2/Dissertation/RTest/Maps/Profiles.xlsx')

# SPARQL query variable to retrieve data zones and their respective SIMD rank values
query1 <- 'PREFIX qb: <http://purl.org/linked-data/cube#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX sdmx: <http://purl.org/linked-data/sdmx/2009/concept#>
PREFIX data: <http://statistics.gov.scot/data/>
PREFIX sdmxd: <http://purl.org/linked-data/sdmx/2009/dimension#>
PREFIX mp: <http://statistics.gov.scot/def/measure-properties/>
PREFIX stat: <http://statistics.data.gov.uk/def/statistical-entity#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
SELECT ?dataZone ?SIMDrank
WHERE {
    ?indicator qb:dataSet data:scottish-index-of-multiple-deprivation;
              <http://statistics.gov.scot/def/dimension/simdDomain> <http://statistics.gov.scot/def/concept/simd-domain/simd>;
              mp:rank ?SIMDrank;
              sdmxd:refPeriod <http://reference.data.gov.uk/id/year/2020> ;
              sdmxd:refArea ?area.
    ?area rdfs:label ?dataZone.
}'

# SPARQL endpoint to retrieve the data
endpoint <- "http://statistics.gov.scot/sparql"

# Assign output of SPARQL query to 'qddata'
qddata <- SPARQL(endpoint, query1)

# Assign results of SPARQL query to data frame 'SIMDrank'
SIMDrank <- qddata$results

# SPARQL query to retrieve data zones, council areas and council area codes
query2 <- 'PREFIX qb: <http://purl.org/linked-data/cube#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX sdmx: <http://purl.org/linked-data/sdmx/2009/concept#>
PREFIX data: <http://statistics.gov.scot/data/>
PREFIX sdmxd: <http://purl.org/linked-data/sdmx/2009/dimension#>
PREFIX mp: <http://statistics.gov.scot/def/measure-properties/>
PREFIX stat: <http://statistics.data.gov.uk/def/statistical-entity#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
SELECT ?dataZone ?councilArea ?councilAreaCode 
WHERE {
    ?dz <http://statistics.gov.scot/def/hierarchy/best-fit#council-area> ?ca.
    ?ca rdfs:label ?councilArea.
    ?ca <http://publishmydata.com/def/ontology/foi/code> ?councilAreaCode. 
    ?dz rdfs:label ?dataZone.
}'

# Assign output of SPARQL query to 'qddata2'
qddata2 <- SPARQL(endpoint, query2)

# Assign results of SPARQL query to data frame 'geo_lkpa'
geo_lkpa <- qddata2$results

# Join the geo_1kpa to Excel file to add profile information
geo_lkp <- inner_join(excelprof, geo_lkpa, by="councilAreaCode")

# Join the 2 data frames to link SIMD to council areas
SIMD_ca_2020 <- inner_join(SIMDrank, geo_lkp, by="dataZone")

# Join the new data frame to the Excel data for 2016
SIMD_ca_2016 <- inner_join(excel2016, geo_lkp, by="dataZone")

# Join the new data frame to the Excel data for 2012
SIMD_ca_2012 <- inner_join(excel2012, geo_lkp, by="dataZone")

# Join the new data frame to the Excel data for 2009
SIMD_ca_2009 <- inner_join(excel2009, geo_lkp, by="dataZone")

# Join the new data frame to the Excel data for 2006
SIMD_ca_2006 <- inner_join(excel2006, geo_lkp, by="dataZone")

# Join the new data frame to the Excel data for 2004
SIMD_ca_2004 <- inner_join(excel2004, geo_lkp, by="dataZone")

# Calculate mean SIMD rank per council area for 2020
SIMD_mean_2020 <- SIMD_ca_2020 %>% 
  group_by(councilAreaCode, councilArea, councilProfile) %>% 
  summarise(meanSIMDrank=mean(SIMDrank))

# Calculate mean SIMD rank per council area for 2016
SIMD_mean_2016 <- SIMD_ca_2016 %>% 
  group_by(councilAreaCode, councilArea, councilProfile) %>% 
  summarise(meanSIMDrank2=mean(SIMD2016))

# Calculate mean SIMD rank per council area for 2012
SIMD_mean_2012 <- SIMD_ca_2012 %>% 
  group_by(councilAreaCode, councilArea, councilProfile) %>% 
  summarise(meanSIMDrank3=mean(SIMD2012))

# Calculate mean SIMD rank per council area for 2009
SIMD_mean_2009 <- SIMD_ca_2009 %>% 
  group_by(councilAreaCode, councilArea, councilProfile) %>% 
  summarise(meanSIMDrank4=mean(SIMD2009))

# Calculate mean SIMD rank per council area for 2006
SIMD_mean_2006 <- SIMD_ca_2006 %>% 
  group_by(councilAreaCode, councilArea, councilProfile) %>% 
  summarise(meanSIMDrank5=mean(SIMD2006))

# Calculate mean SIMD rank per council area for 2004
SIMD_mean_2004 <- SIMD_ca_2004 %>% 
  group_by(councilAreaCode, councilArea, councilProfile) %>% 
  summarise(meanSIMDrank6=mean(SIMD2004))

# Load shapefile into R as spatial polygons data frame
boundary <- readOGR(dsn="C:/Users/Jac/Documents/BSc Computing Year 4 Pt2/Dissertation/RTest/Maps", layer="Local_Authority_Districts_December_2017_Ultra_Generalised_Clipped_Boundaries_in_United_Kingdom_WGS84")

# Merge spatial polygons data frame with data frame containing mean for 2020
merged_2020 <- merge(boundary, SIMD_mean_2020, by.x = "lad17nm", 
                by.y = "councilArea", all.x = FALSE)

# Merge spatial polygons data frame with data frame containing mean for 2016
merged_2016 <- merge(boundary, SIMD_mean_2016, by.x = "lad17nm", 
                     by.y = "councilArea", all.x = FALSE)

# Merge spatial polygons data frame with data frame containing mean for 2012
merged_2012 <- merge(boundary, SIMD_mean_2012, by.x = "lad17nm", 
                     by.y = "councilArea", all.x = FALSE)

# Merge spatial polygons data frame with data frame containing mean for 2009
merged_2009 <- merge(boundary, SIMD_mean_2009, by.x = "lad17nm", 
                     by.y = "councilArea", all.x = FALSE)

# Merge spatial polygons data frame with data frame containing mean for 2006
merged_2006 <- merge(boundary, SIMD_mean_2006, by.x = "lad17nm", 
                     by.y = "councilArea", all.x = FALSE)

# Merge spatial polygons data frame with data frame containing mean for 2004
merged_2004 <- merge(boundary, SIMD_mean_2004, by.x = "lad17nm", 
                     by.y = "councilArea", all.x = FALSE)

# Project 2020 data to World Geodetic System 1984 using spTransform to ensure correct plotting
project_2020 <- spTransform(merged_2020, 
                         CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))

# Project 2016 data to World Geodetic System 1984 using spTransform to ensure correct plotting
project_2016 <- spTransform(merged_2016, 
                            CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))

# Project 2012 data to World Geodetic System 1984 using spTransform to ensure correct plotting
project_2012 <- spTransform(merged_2012, 
                            CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))

# Project 2009 data to World Geodetic System 1984 using spTransform to ensure correct plotting
project_2009 <- spTransform(merged_2009, 
                            CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))

# Project 2006 data to World Geodetic System 1984 using spTransform to ensure correct plotting
project_2006 <- spTransform(merged_2006, 
                            CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))

# Project 2004 data to World Geodetic System 1984 using spTransform to ensure correct plotting
project_2004 <- spTransform(merged_2004, 
                            CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))

# Create bins and palette for mean SIMD rank
bins <- c(1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 6000)
pal <- colorBin("YlOrRd", domain = project_2020$meanSIMDrank, bins = bins)

# Create leaflet plot and add polygon layers for each SIMD reporting year
lplot <- leaflet(data = boundary) %>% 
  addProviderTiles("CartoDB.Positron", 
                   options= providerTileOptions(opacity = 0.99)) %>% 
  addPolygons(data = project_2020, # first group
              fillColor = ~pal(meanSIMDrank),
              weight = 2,
              opacity = 1,
              color = "white",
              dashArray = "3",
              fillOpacity = 0.7,
              highlight = highlightOptions(
                weight = 2,
                color = "#666",
                dashArray = "",
                fillOpacity = 0.7,
                bringToFront = TRUE),
              group = "SIMD2020",
              popup =~paste("Local Authority: ",project_2020$lad17nm,"<br>",
                            "Mean SIMD: ",round(project_2020$meanSIMDrank),"<br>",
                            "<a href =\"",project_2020$councilProfile, "\", target=\"_blank\">Population Details</a>"),
              popupOptions = popupOptions(textsize = "12px",
                                          direction = "auto")) %>%
  addPolygons(data = project_2016, # second group
              fillColor = ~pal(meanSIMDrank2),
              weight = 2,
              opacity = 1,
              color = "white",
              dashArray = "3",
              fillOpacity = 0.7,
              highlight = highlightOptions(
                weight = 2,
                color = "#666",
                dashArray = "",
                fillOpacity = 0.7,
                bringToFront = TRUE),
              group = "SIMD2016",
              popup =~paste("Local Authority: ",project_2016$lad17nm,"<br>",
                            "Mean SIMD: ",round(project_2016$meanSIMDrank2),"<br>",
                            "<a href =\"",project_2016$councilProfile, "\", target=\"_blank\">Population Details</a>"),
              popupOptions = popupOptions(textsize = "12px",
                                          direction = "auto")) %>%
  addPolygons(data = project_2012, # third group
              fillColor = ~pal(meanSIMDrank3),
              weight = 2,
              opacity = 1,
              color = "white",
              dashArray = "3",
              fillOpacity = 0.7,
              highlight = highlightOptions(
                weight = 2,
                color = "#666",
                dashArray = "",
                fillOpacity = 0.7,
                bringToFront = TRUE),
              group = "SIMD2012",
              popup =~paste("Local Authority: ",project_2012$lad17nm,"<br>",
                            "Mean SIMD: ",round(project_2012$meanSIMDrank3),"<br>",
                            "<a href =\"",project_2012$councilProfile, "\", target=\"_blank\">Population Details</a>"),
              popupOptions = popupOptions(textsize = "12px",
                                          direction = "auto")) %>%
  addPolygons(data = project_2009, # fourth group
              fillColor = ~pal(meanSIMDrank4),
              weight = 2,
              opacity = 1,
              color = "white",
              dashArray = "3",
              fillOpacity = 0.7,
              highlight = highlightOptions(
                weight = 2,
                color = "#666",
                dashArray = "",
                fillOpacity = 0.7,
                bringToFront = TRUE),
              group = "SIMD2009",
              popup =~paste("Local Authority: ",project_2009$lad17nm,"<br>",
                            "Mean SIMD: ",round(project_2009$meanSIMDrank4),"<br>",
                            "<a href =\"",project_2009$councilProfile, "\", target=\"_blank\">Population Details</a>"),
              popupOptions = popupOptions(textsize = "12px",
                                          direction = "auto")) %>%
  addPolygons(data = project_2006, # fifth group
              fillColor = ~pal(meanSIMDrank5),
              weight = 2,
              opacity = 1,
              color = "white",
              dashArray = "3",
              fillOpacity = 0.7,
              highlight = highlightOptions(
                weight = 2,
                color = "#666",
                dashArray = "",
                fillOpacity = 0.7,
                bringToFront = TRUE),
              group = "SIMD2006",
              popup =~paste("Local Authority: ",project_2006$lad17nm,"<br>",
                            "Mean SIMD: ",round(project_2006$meanSIMDrank5),"<br>",
                            "<a href =\"",project_2006$councilProfile, "\", target=\"_blank\">Population Details</a>"),
              popupOptions = popupOptions(textsize = "12px",
                                          direction = "auto")) %>%
  addPolygons(data = project_2004, # sixth group
              fillColor = ~pal(meanSIMDrank6),
              weight = 2,
              opacity = 1,
              color = "white",
              dashArray = "3",
              fillOpacity = 0.7,
              highlight = highlightOptions(
                weight = 2,
                color = "#666",
                dashArray = "",
                fillOpacity = 0.7,
                bringToFront = TRUE),
              group = "SIMD2004",
              popup =~paste("Local Authority: ",project_2004$lad17nm,"<br>",
                           "Mean SIMD: ",round(project_2004$meanSIMDrank6),"<br>",
                           "<a href =\"",project_2004$councilProfile, "\", target=\"_blank\">Population Details</a>"),
              popupOptions = popupOptions(textsize = "12px",
                                          direction = "auto")) %>%
  addLegend(pal = pal, 
            values = ~bins, 
            opacity = 0.7, 
            title = "Mean SIMD Rank",
            position = "bottomright") %>%

leaflet::addLayersControl(
                baseGroups = c("SIMD2004","SIMD2006","SIMD2009","SIMD2012","SIMD2016","SIMD2020"),
                 position = "topright",
                 options = layersControlOptions(collapsed = FALSE))

lplot # display map