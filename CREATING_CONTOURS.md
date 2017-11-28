# Preparing data for Open Street Map rendering.

These instructions explain how to prepare contour data for rendering in Open Street
Map.  As well as following these, refer also to the DOCKER.md instructions 
first.  The tasks are related.

Information on adding contours is based on the [Open Street
Map Wiki Contours page](http://wiki.openstreetmap.org/wiki/Contours).  The
styling information has already been incorporated into the _project.mml_ and
_contours.mss_ files.

The examples and data here are based on generating contours for the St Vincent
and the Grenadines region.  This region is used by the Overseas Development
Agency multihazard app.


## Before you start

Requirements:

* A Linux system running Docker
* GDAL/OGR libraries for manipulating GIS files
* Python `elevation` tool for downloading DEM data (requires _fiona_ library to
  get extents from reference files).
* `osmctools` for manipulating OSM files

Test that you can run Docker:

```
docker run hello-world
```

Create a Docker volume to persitently store PostGIS data:

```
docker volume create --name=osm-pgdata -d local
```

Other dependencies can be installed on Debian/Linux based systems with:

```
sudo apt install gdal-bin python-pip osmctools
sudo pip install elevation fiona
```

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

Ready-made pbf files for larger regions e.g. Central America can be download
from [Geofabrik](http://download.geofabrik.de/).


## Import OSM data

Data are imported using the docker-compose import command.  It is called with
a number of environment variables preset.  See [DOCKER.md](DOCKER.md) for
details.

```
PG_WORK_MEM=128MB PG_MAINTENANCE_WORK_MEM=2GB \
OSM2PGSQL_CACHE=2048 OSM2PGSQL_NUMPROC=4 \
OSM2PGSQL_DATAFILE=svg/svg.osm.pbf \
docker-compose up import 
```

Note the path to the file to import.


## Create a land mask for downloading and clipping SRTM data

> Note: a mask for St Vincent and the Grenadines is present at
> svg/svg_land_mask_4326.geojson

The following steps are necessary because the SRTM data has been interpolated
and contains artefacts within the sea where the elevation is greater than zero.

The following instructions assume that you are using QGIS.

1. Download the [OpenStreetMap coastline data](http://data.openstreetmapdata.com/land-polygons-split-3857.zip) and add to map
2. Zoom to area of interest and select all polygons
3. Right-click and Save As (geojson, EPSG:4326, only selection, extents=map view, 2 decimal
   places) e.g. svg_land_polygons_4326
4. Merge into single multipolygon via _Vector > Geoprocessing > Dissolve_
   (dissolve all) e.g. svg_land_mask_4326.shp
5. _Optional:_ convert to geojson with 'Save As' to stop shapefiles cluttering
   directory


## Generate contours

The following steps download a DEM from the Shuttle Radar Topography Mission
(SRTM) project and calculate contours.  The land mask is applied because the
original data have been interpolated and the sea contains artefacts that result
in 'islands' appearing that do not exist.  The mask must be in EPSG:4326
projection.

```
# Download data
cd svg
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
psql -h <hostname> -U postgres -d gis -c 'SELECT 1;'
```

The data are loaded via shp2pgsql by running the following commands within the
shapefile directory:

```
cd svg_srtm_30m_contours_10m
shp2pgsql -p -I -g way -s 4326:900913 contour.shp contour | psql -h localhost -p 5432 -U postgres -d gis
shp2pgsql -a -g way -s 4326:900913 contour.shp contour | psql -h localhost -p 5432 -U postgres -d gis
```


## Start Kosmtik

You should now be able to start Kosmtik and see the map with contours.

```
docker-compose up kosmtik
```

Stop Kosmtik with <ctrl-C>.  To run as a background process, run the following
command:

```
docker-compose up -d kosmtik
```


## Exporting as mbtiles

A script is used to export the data in [mbtiles](http://wiki.openstreetmap.org/wiki/MBTiles) format.  The exported region and zoom levels can be configured via environment variables in the _docker-compose.yml_ file.

With the kosmtik container running (see above), run the following command:

```
docker exec --user root openstreetmapcarto_kosmtik_1 \
/openstreetmap-carto/scripts/export_mbtiles.sh
```

Note that the MBTILES_FILE location refers to within the docker container,
however the /openstreetmap-carto folder is accessible from outside.  Changes
made to the docker-compose.yml file will only be reflected in the container
following a container restart.

The export can take a long time (hours).  You can view progress by inspecting
the number of tiles within the mbtiles file with the following:

```
watch 'sqlite3 data/svg.mbtiles \
 "SELECT zoom_level, COUNT(1) \
  FROM tiles GROUP BY zoom_level;"'
```


## Viewing the exported tiles

The `docker-compose.yml` file also contains instructions to set up an nginx
webserver serving a Leaflet map allowing the data to be browsed.  Assuming that
the mbtiles file is located at data/svg.mbtiles, the webmap can be accessed at
[http://localhost](http://localhost).


## Troubleshooting

### No tiles for the world

If you find that Kosmtik starts, but there are no tiles for the world and there
is an error about missing Shapefiles, it may be due to a permissions error.
The docker user needs to be set to the correct ID.

Find your id

```
id -u
```

Update _Dockerfile_ with e.g. `USER 1000`, then rebuild and restart the
containers.

```
docker-compose build
docker-compose up kosmtik
```

## eio "Reference datasource could not be opened"

This is due to a bug in the spatial.py file of eio version 1.0.1.  If you have
 this (`eio --version` to check), then the second SUPPORT_RASTER_DATA should be
replaced with SUPPORT_VECTOR_DATA.  This error message may also show if the
`fiona` python library is not present.


## Problems with bounds in exported mbtiles file

This may be a result of this
[bug](https://github.com/kosmtik/kosmtik-mbtiles-export/commit/4da99650f690e3e35f05bd97679ae992c18a3cb1),
which has been fixed in Github, but not in the version of code installed in the
container.
