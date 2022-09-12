# PACKAGES
library(tidyverse) # data wrangling
library(stringr)   # work with strings
library(sf)        # geospatial
library(geosphere) # calculate distances
library(haven)     # read/write .dta (Stata)
library(here)      # use relative filepaths
library(osrm)      # calculate road distances
library(assertthat)


# old spatial packages since osrm works with those
library(sp) #spatial objects; used by rgdal


# Read in data set 
dataset = read_dta(here::here("folder", "dta.dta"))


# Convert to SpatialPointsDataFrame for use with osrmTable
dataset_spdf <- dataset %>% as('Spatial')


# Use OSRM's server
options(osrm.server = "http://router.project-osrm.org/")
# NOTE: above uses OSRM's server. If we try one with more than 10,000 queries:

# We get the error:
# OSRM returned an error:
# Error: The public OSRM API does not allow results with a number of durations 
# higher than 10000. Ask for fewer durations or use your own server and set its 
# --max-table-size option.

# Now try it on a local server to avoid the 10,000 query limit:


# Once the local server is running:
options(osrm.server = "http://localhost:5000/")
#Compute distances
distances <- osrmTable(src = src, dst = dst)
