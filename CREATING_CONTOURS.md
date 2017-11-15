
# Preparing data for Open Street Map rendering.

These instructions explain how to prepare data for rendering in Open Street
Map.

Information on adding contours is based on the [Open Street
Map Wiki Contours page](http://wiki.openstreetmap.org/wiki/Contours).  The
styling information has already been incorporated into the _project.mml_ and
_contours.mss_ files.


## Create a land mask for downloading and clipping SRTM data

> Note: a mask for St Vincent and the Grenadines is present at
> svg/svg_land_mask_4326.geojson

The following steps are necessary because the SRTM data has been interpolated
and contains artefacts within the sea where the elevation is greater than zero.

1. Add QuickMapServices plugin to QGIS
2. Add background OSM map via _Web > QuickMapServices > OSM_
3. Zoom to region of interest
4. Download the [OpenStreetMap coastline data](http://data.openstreetmapdata.com/land-polygons-split-3857.zip) and add to map
5. Zoom to area of interest and select all polygons
6. Right-click and Save As (geojson, EPSG:4326, only selection, extents=map view, 2 decimal
   places) e.g. svg_land_polygons_4326
7. Merge into single multipolygon via _Vector > Geoprocessing > Dissolve_
   (dissolve all) e.g. svg_land_mask_4326.shp
8. _Optional:_ convert to geojson with 'Save As' to stop shapefiles cluttering
   directory


## Download OSM data for region of interest

> Note: OSM data for St Vincent and the Grenadines is present at
> svg/svg.osm.pbf

The data can be downloaded directly via QGIS.  This produces XML output.  It
should be converted to _.pbf_ format for loading into PostGIS.

1. In QGIS, zoom to the region of interest
2. Select _Vector > OpenStreetmap > Download data_
3. Choose a name for the output file (add .xml as extension)
4. Press OK

To convert the data, the `osmconvert` utility is required.  It is part of the
`osmctools` package in Debian/Ubuntu Linux systems.

```
osmconvert svg.osm.xml --out-pbf > svg.osm.pbf
```

It will be imported when the docker-compose import
command is run.  See [DOCKER.md](file://./DOCKER.md) for details.

```
PG_WORK_MEM=128MB PG_MAINTENANCE_WORK_MEM=2GB \
OSM2PGSQL_CACHE=2048 OSM2PGSQL_NUMPROC=4 \
OSM2PGSQL_DATAFILE=${pwd}/svg/svg.osm.pbf \
docker-compose up import 
```

## Generate contours

The following steps download a DEM from the Shuttle Radar Topography Mission
(SRTM) project and calculate contours.  The land mask is applied because the
original data have been interpolated and the sea contains artefacts that result
in 'islands' appearing that do not exist.  The mask must be in EPSG:4326
projection.

```
# Install elevation package
pip install elevation

# Download data
eio clip -o svg_srtm_30m_raw.tif --reference svg_land_mask_4326.geojson

# Remove bad data from sea
gdalwarp -cutline svg_land_mask_4326.geojson -crop_to_cutline svg_srtm_30m_raw.tif svg_srtm_30m.tif

# Calculate contours
gdal_contour -i 10 -a height svg_srtm_30m.tif svg_srtm_30m_contours_10m
```

## Load contour data to database

Ensure that the database is running and that you can connect to it.  You can
test connection with:

```
psql -h <hostname> -p <port> -U postgres -d gis -c 'SELECT 1;'
```

The data are loaded via shp2pgsql by running the following commands within the
shapefile directory:

```
shp2pgsql -p -I -g -s 4326:900913 way contour.shp contour | psql -h hwlosm -p 5432 -U postgres -d gis
shp2pgsql -a -g way -s 4326:900913 contour.shp contour | psql -h hwlosm -p 5432 -U postgres -d gis
```
