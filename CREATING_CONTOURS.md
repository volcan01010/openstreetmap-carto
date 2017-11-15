
# Creating data for Open Street Map rendering.

## Create a land mask for downloading and clipping SRTM data

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


## Generate contours

The following steps download a DEM from the Shuttle Radar Topography Mission
(SRTM) project and calculate contours.  The land mask is applied because the
original data have been interpolated and the sea contains artefacts that result
in 'islands' appearing that do not exist.


```
# Download
eio clip -o svg_srtm_30m_raw.tif --reference svg_land_mask_4326.geojson

# Remove bad data from sea
gdalwarp -cutline svg_land_mask_4326.geojson -crop_to_cutline svg_srtm_30m_raw.tif svg_srtm_30m.tif

# Calculate contours
gdal_contour -i 10 -a height svg_srtm_30m.tif svg_srtm_30m_contours_10m
```

## Download OSM data for region of interest

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

The pbf file can be read into PostGIS

```
shp2pgsql -p -I -g -s 900913 way contour.shp contour | psql -h hwlosm -p 5432 -U postgres -d gis
shp2pgsql -a -g way -s 900913 contour.shp contour | psql -h hwlosm -p 5432 -U postgres -d gis
```










# Old
Instructions for adding contours to OSM maps can be found on the [Open Street
Map Wiki Contours page](http://wiki.openstreetmap.org/wiki/Contours).

The Admin bounday for St Vincent and the Grenadines was manually extracted from
the Open Street Map data within QGIS.  The polygons from the
[Open Street Map data website](http://openstreetmapdata.com/data/land-polygons
land-polygons-split-3857.shp) were then clipped to the resulting
`st_vincent_and_the_grenadines_admin_area_4326.geojson` file.  They were then
_dissolved_ in QGIS to make the land_mask.geojson file, which was in 4326
projection with extents stored inside.


The contour shape files were created with:

```
# Note that:
# 'eio' is provided by the *elevation* Python package (`pip install elevation`).
# The 'reference' mask must be in EPGS:4326 projection, with defined extents

eio clip -o st_vincent_srtm_30m.tif --reference st_vincent_and_the_grenadines_land_mask.geojson 
gdal_contour -i 10 -a height st_vincent_srtm_30m.tif st_vincent_srtm_30m_contour_10.shp
```

The contour files were _intersected_ in QGIS to remove data from the sea, which
contained interpolation artefacts.  The new versions had 'clean' appended to
their names.

The data were then loaded into PostGIS as follows:
```
shp2pgsql -p -I -g geom st_vincent_srtm_30m_contour_10_clean.shp contour | psql -h hwlosm -d gis -U www-data
shp2pgsql -a -g geom st_vincent_srtm_30m_contour_10_clean.shp contour | psql -h hwlosm -d gis -U www-data
```


  422  ls
  423  docker build -t zavpyj/osm-tiles .
  424  docker run busybox nslookup google.com
  425  nmcli dev show 
  426  sudo -i
  427  docker run busybox nslookup google.com
  428  docker build -t zavpyj/osm-tiles .
  429  docker volume --help
  430  docker volume create --help
  431  docker run --help
  432  docker run --rm zavpyj/osm-tiles
  433  docker volume create --name nvpostgisdata -d local
  434  docker volume create --name nvtiles -d local
  435  docker run --rm -v nvpostgisdata:/var/lib/postgresql zavpyj/osm-tiles initdb
  436  ping 192.171.143.126
  437  ping 10.179.0.52
  438  ls
  439  history
  440  ls
  441  gvim README.md &
  442  sudo apt install docker-compose 
  443  gvim README.md &
  444  docker-compose run --rm app-osm initdb
  445  docker-compose run --rm app-osm import
  446  docker-compose run --rm app-osm startdb 
  447  docker-compose up
  448  docker volumes
  449  docker volume
  450  docker volume ls
  451  docker volume inspect nvpostgisdata 
  452  sudo -i
  453  docker ps
  454  docker ps -a
  455  docker ps -a1
  456  docker ps --help
  457  docker ps -q
  458  docker ps -qa
  459  docker ps -qa | xargs docker rm
  460  docker ps
  461  docker ps -a
  462  docker images
  463  df -h
  464  docker ps
  465  docker ps -a
  466  docker volumes ls
  467  docker volume ls
  468  docker volume rm nvpostgisdata 
  469  docker volume create nvpostgisdata -d local
  470  docker volume inspect nvpostgisdata 
  471  ls -l /var/lib/docker/volumes
  472  ls -l /var/lib/docker/
  473  ls -l /var/lib
  474  sudo chown root:docker -R /var/lib/docker
  475  ls -l /var/lib
  476  ls /var/lib/docker/
  477  groups
  478  cd ~/data/osm-postgresql/9.5/main/
  479  ls
  480  cd ~/data/osm-postgresql/
  481  ls -l
  482  sudo -i
  483  sudo -i .
  484  sudo -i 
  485  docker ps -a1
  486  docker ps -aq | xargs docker rm -f
  487  ls
  488  sudo apt install postgresql postgis
  489  ls -l /etc/postgresql/9.6/main/
  490  ls -l /var/run/
  491  docker -D info
  492  docker version
  493  free -h
  494  docker volume inspect nvpostgisdata 
  495  df -h
  496  ifconfig
  497  lsb_release 
  498  ls -sh ~/data/pbf/
  499  exit
  500  docker volume rm nvpostgisdata 
  501  sudo du -a / | sort -n -r | head -n 5
  502  find /home/jostev/dev/tiles/png -iname *.png | head 
  503  eog /home/jostev/dev/tiles/png/10/328/472.png 
  504  du -sh ~/dev/tiles/png/*
  505  du -sh ~/dev/tiles/png
  506  find /home/jostev/dev/tiles/png -iname *.png | tail
  507  docker ps
  508  docker inspect osmtilesdocker_app-osm_1 
  509  psql -h 172.18.0.2 -p 5432 -U www-data -d gis
  510  docker exec -it osmtilesdocker_app-osm_1 /bin/bash
  511  ls
  512  docker images
  513  docker ps
  514  docker ps -a
  515  ls
  516  du -a /home | sort -n -r | head
  517  cd osm-tiles-docker/
  518  ls
  519  git status
  520  git diff
  521  gvim docker-compose.yml &
  522  mkdir ~/dev/tiles
  523  ls
  524  ls ~/dev
  525  docker volume rm nvtiles 
  526  mkdir ~/dev/postgisdata
  527  docker-compose run --rm app-osm initdb
  528  git diff
  529  docker-compose run --rm app-osm initdb
  530  ls
  531  mv ~/data/pbf/bretagne-latest.osm.pbf ~/dev/ -v
  532  ls ~
  533  tree -sh data
  534  tree -sh ~/data
  535  rm ~/data/osm-postgresql/
  536  rm ~/data/osm-postgresql/ -r
  537  rm ~/data/osm-postgresql/ -rf
  538  sudo rm ~/data/osm-postgresql/ -rf
  539  tree -sh ~/data
  540  du -sh /var/log | sort -rh | head -n 5
  541  sudo du -sh /var/log | sort -rh | head -n 5
  542  sudo du -sh /var/log/* | sort -rh | head -n 5
  543  sudo apt-remove --purge libreoffice
  544  sudo apt remove --purge libreoffice
  545  sudo apt remove --purge libreoffice-*
  546  git diff
  547  docker volume ls
  548  docker volume ls -f dangling=true
  549  docker volume remove $(docker volume ls -f dangling=true)
  550  docker volume rm $(docker volume ls -f dangling=true)
  551  docker volume ls
  552  docker volume create nvpostgisdata -d local
  553  docker volume create nvtiles -d local
  554  docker-compose run --rm app-osm initdb
  555  docker-compose run --rm app-osm import
  556  docker-compose run --rm app-osm render
  557  docker-compose up -d
  558  docker volume inspect nvtiles
  559  sudo cp /var/lib/docker/volumes/nvtiles/_data/* /home/jostev/dev/tiles/
  560  sudo cp /var/lib/docker/volumes/nvtiles/_data/ /home/jostev/dev/tiles/
  561  sudo cp /var/lib/docker/volumes/nvtiles/_data/ /home/jostev/dev/tiles/ -r
  562  sudo du -sh /var/lib/docker/volumes/nvtiles
  563  ls
  564  docker-compose run --rm app-osm cli
  565  ls
  566  cd ..
  567  git clone https://github.com/openstreetmap/mod_tile.git
  568  cd mod_tile/extra/
  569  ls
  570  cat README 
  571  make
  572  cd ..
  573  ls
  574  cd ..
  575  ls
  576  cd osm-tiles-docker/
  577  docker-compose run --rm app-osm cli
  578  sudo apt-install build-essential
  579  sudo apt install build-essential
  580  cd ..
  581  ls
  582  git clone https://github.com/geofabrik/meta2tile
  583  cd meta2tile/
  584  make
  585  cd ..
  586  find mod_tile/ -iname *.h
  587  cd -
  588  ls
  589  cat README.md 
  590  find /lib* -iname sqlite.h
  591  find /lib* -iname sqlite3.h
  592  find / -iname sqlite3.h
  593  sudo apt install libsqlite3-dev
  594  make
  595  apt search openssl
  596  sudo apt install libsqlite3-dev libssl-dev
  597  make
  598  apt search ogr
  599  apt search gdal
  600  sudo apt install libsqlite3-dev libgdal-dev
  601  make
  602  apt search zip.h
  603  apt search libzip
  604  sudo apt install libsqlite3-dev libgdal-dev libzip-dev
  605  make
  606  apt search libgd
  607  apt search libgd-dev
  608  sudo apt install libsqlite3-dev libgdal-dev libzip-dev libgd-dev
  609  make
  610  ls
  611  mkdir ~/dev/tiles/png
  612  /home/jostev/meta2tile/meta2tile ~/dev/tiles/_data/default/ ~/dev/tiles/png/
  613  /home/jostev/meta2tile/meta2tile ~/dev/tiles/_data/default ~/dev/tiles/png
  614  tree ~/dev/tiles/png
  615  tree ~/dev/tiles/_data/default/
  616  find /home/jostev/dev/tiles/_data/default/14 -iname *.meta
  617  find /home/jostev/dev/tiles/_data/default/14 -iname *.meta | ./meta2tile --list
  618  find /home/jostev/dev/tiles/_data/default/14 -iname *.meta | ./meta2tile --list /tmp
  619  find /home/jostev/dev/tiles/_data/default/14 -iname *.meta -print0
  620  find /home/jostev/dev/tiles/_data/default/14 -iname *.meta
  621  rm ~/dev/tiles/png/*
  622  rm ~/dev/tiles/png/* -rf
  623  ./meta2tile ~/dev/tiles/_data/default/14 ~/dev/tiles/png
  624  ./meta2tile ~/dev/tiles/_data/default/10 ~/dev/tiles/png
  625  tree ~/dev/tiles/_data/default/10/
  626  ./meta2tile ~/dev/tiles/_data/ ~/dev/tiles/png
  627  ls
  628  ./meta2tile ~/dev/tiles/_data/ ~/dev/tiles/png
  629  lsblk
  630  sudo -i
  631  exit
  632  docker images
  633  docker volume ls
  634  du -sh /var/run/docker
  635  sudo du -sh /var/run/docker
  636  sudo du -sh /var/run/docker/*
  637  sudo du -sh /var/run/docker/
  638  sudo du -sh /var/lib/docker/
  639  lsblk
  640  sudo -i
  641  exit
  642  sudo apt install qgis qgis-plugin-grass 
  643  apt --help
  644  apt install --help
  645  man apt
  646  sudo apt install --install-suggests qgis qgis-plugin-grass
  647  sudo apt install --install-recommended qgis qgis-plugin-grass
  648  sudo apt install --install-recommends qgis qgis-plugin-grass
  649  df -h
  650  sudo -i
  651  docker images
  652  cd osm-tiles-docker/
  653  ls
  654  docker-compose run --rm app-osm dropdb
  655  docker ps
  656  docker volume rm nvpostgisdata 
  657  ls
  658  docker volume rm nvpostgisdata -f
  659  docker volume rm nvtiles -f
  660  docker volume create nvpostgisdata -d local
  661  docker volume create nvtiles -d local
  662  docker-compose run --rm app-osm initdb
  663  ls /var/lib/docker
  664  sudo ls /var/lib/docker
  665  sudo ls /var/lib/docker/volumes
  666  docker ps -a
  667  docker rm -f 226
  668  docker-compose run --rm app-osm initdb
  669  docker volume rm nvpostgisdata -f
  670  gvim docker-compose.yml &
  671  docker-compose run --rm app-osm initdb
  672  docker volume create nvpostgisdata -d local
  673  docker-compose run --rm app-osm initdb
  674  docker-compos
  675  docker-compose run --rm app-osm render
  676  docker-compose up -d
  677  docker ps
  678  docker exec -it osmtilesdocker_app-osm_1 /bin/bash
  679  ls
  680  cd ..
  681  ls
  682  cd meta2tile/
  683  ls
  684  docker container inspect nvtiles
  685  docker container inspect nvtile
  686  docker container ls
  687  docker volume inspect nvtiles
  688  ls
  689  cd 
  690  ls
  691  docker ps
  692  cd ../..
  693  ls
  694  cd osm-tiles-docker/
  695  ls
  696  docker-compose run --rm app-osm -d
  697  docker-compose run --rm app-osm cli
  698  ls
  699  git status
  700  git diff
  701  ls
  702  docker build -t zavpyj/osm-tiles .
  703  docker-compose run --rm app-osm create_pngs
  704  docker build -t zavpyj/osm-tiles .
  705  docker-compose run --rm app-osm create_pngs
  706  docker-compose run --rm app-osm create_pngs > /tmp/out
  707  less /tmp/out 
  708  docker build -t zavpyj/osm-tiles .
  709  docker-compose run --rm app-osm create_pngs
  710  git remote update
  711  git remote -v
  712  sudo -i
  713  git status
  714  git add Dockerfile README.md build/run.sh 
  715  git commit 
  716  git status
  717  git commit --amend
  718  git status
  719  git log --oneline
  720  git config
  721  git config -l
  722  git remote add volcan01010 https://github.com/volcan01010/osm-tiles-docker.git
  723  git remote update
  724  git diff volcan01010/master
  725  git diff master:volcan01010/master
  726  git diff master volcan01010/master
  727  gitg
  728  sudo apt install gitg
  729  gitg &
  730  git checkout -b add-create-png
  731  git status
  732  git push -u volcan01010 add-create-png 
  733  ls
  734  cd ..
  735  ls
  736  rm meta2tile/
  737  rm meta2tile/ -rf
  738  ping hwlgmci
  739  ping hwlosm
  740  ssh hwlosm
  741  exit
  742  docker volume inspect nvtiles
  743  sudo cp /media/dockerdata/volumes/nvtiles/_data /tmp
  744  sudo cp /media/dockerdata/volumes/nvtiles/_data /tmp -r
  745  cd /tmp
  746  ls
  747  sudo chone jostev:jostev -R _data/
  748  sudo chown jostev:jostev -R _data/
  749  /home/jostev/meta2tile/meta2tile _data/default/ /home/jostev/dev/tiles/png
  750  find /home/jostev/dev/tiles/png/ -iname "*.png"
  751  /home/jostev/meta2tile/meta2tile _data/default/10 /home/jostev/dev/tiles/png/10
  752  gvim ~/meta2tile/meta2tile.c &
  753  /home/jostev/meta2tile/meta2tile --help
  754  /home/jostev/meta2tile/meta2tile _data/default/10 /home/jostev/dev/tiles/png/10 --tojpeg
  755  /home/jostev/meta2tile/meta2tile _data/default/4 /home/jostev/dev/tiles/png/4 --tojpeg
  756  /home/jostev/meta2tile/meta2tile _data/default/ /home/jostev/dev/tiles/png/ --tojpeg
  757  /home/jostev/meta2tile/meta2tile _data/default /home/jostev/dev/tiles/png --tojpeg
  758  /home/jostev/meta2tile/meta2tile _data/default/4 /home/jostev/dev/tiles/png/4
  759  /home/jostev/meta2tile/meta2tile _data/default/5 /home/jostev/dev/tiles/png/5
  760  find /home/jostev/dev/tiles/png/ -iname "*.png"
  761  /home/jostev/meta2tile/meta2tile _data/default/6 /home/jostev/dev/tiles/png/6
  762  /home/jostev/meta2tile/meta2tile _data/default/7 /home/jostev/dev/tiles/png/7
  763  /home/jostev/meta2tile/meta2tile _data/default/7/0/0/0/35/8 /home/jostev/dev/tiles/png/7/0/0/0/35/8
  764  /home/jostev/meta2tile/meta2tile _data/default/7/0/0/0/35 /home/jostev/dev/tiles/png/7/0/0/0/35
  765  cd
  766  ls
  767  cd mod_tile/
  768  git status
  769  cd extra/
  770  ls
  771  make
  772  gvim ~/osm-tiles-docker/Dockerfile &
  773  cd ..
  774  ./autogen.sh 
  775  ls
  776  ./configure
  777  cat autogen.sh 
  778  eog ~/Pictures/Screenshot\ from\ 2017-11-03\ 10-12-47.png &
  779  mv & ~/dev
  780  ls
  781  mv ~/Pictures/Screenshot\ from\ 2017-11-03\ 10-12-47.png ~/dev
  782  sudo -i
  783  history | grep meta2tile
  784  cd /mtp
  785  cd /tmp
  786  meta2tile _data/default /home/jostev/dev/tiles/png
  787  du -sh ~/dev/tiles/png/*
  788  du -sh ~/dev/tiles/png
  789  du -sh ~/dev/tiles/*
  790  tree ~/home/jostev/dev/tiles/png
  791  tree ~/home/jostev/dev/tiles/
  792  tree ~/dev/tiles/
  793  tree ~/dev/tiles/png
  794  tree ~/dev/tiles/ -L 3
  795  tree ~/dev/tiles/ -L 3 -d
  796  tree ~/dev/tiles/ -L 4 -d
  797  find ~/dev/tiles/png -type f -iname '*.png' | wc -l
  798  cd ~
  799  rm ~/dev/tiles/png/* -rf
  800  docker ps
  801  docker ps -a
  802  docker start osmtilesdocker_app-osm_1 
  803  docker exec -it osmtilesdocker_app-osm_1 /bin/bash
  804  ls
  805  cd mod_tile/
  806  git checkout e25bfdba1c1f2103c69529f1a30b22a14ce311f1
  807  ls
  808  cd extra/
  809  ls
  810  ls -a ~
  811  cd ~/.ssh/
  812  ls
  813  ssh-key -t rsa -b 4096 -C "jostev@u1710"
  814  ssh-keygen -t rsa -b 4096 -C "jostev@u1710"
  815  ssh-copy-id hwlosm
  816  ssh hwlosm
  817  ls
  818  cd ..
  819  ls
  820  cp .vim hwlosm:/home/jostev
  821  scp .vim hwlosm:/users/jostev/.vim
  822  scp .vim hwlosm:/users/jostev/.vim -r
  823  scp -r  ~/.vim hwlosm:/users/jostev/.vim
  824  ssh hwlosm
  825  ls
  826  scp data/pbf/central-america-latest.osm.pbf hwlosm:/tmp
  827  cd osm-tiles-docker/
  828  ls
  829  scp docker-compose.yml hwlosm:/users/jostev/osm-tiles-docker/
  830  ssh hwlosm
  831  exit
  832  cd osm-tiles-docker/
  833  git status
  834  cat docker-compose.yml 
  835  diff
  836  git diff
  837  less README.md 
  838  gvim README.md &
  839  git status
  840  echo "1024 * 8 | bc"
  841  echo "1024 * 8" | bc
  842  git diff
  843  git status
  844  git checkout -b st_vincent
  845  git commit -am "Set defaults to load St Vincent"
  846  git push -u volcan01010 st_vincent
  847  git diff master build/index.html
  848  git status
  849  git commit -m "Fix coordinates for Kingstown"
  850  git commit -m "Fix coordinates for Kingstown" -a
  851  git push volcan01010 st_vincent 
  852  git diff
  853  git commit -am "Change default zoom and move St Vincent marker"
  854  git push volcan01010 st_vincent 
  855  ssh hwlosm
  856  cd ..
  857  ls
  858  cd osm-tiles-docker
  859  ls
  860  ls ~/.ssh
  861  cat ~/.ssh/id_rsa | xclip --selection clip
  862  sudo apt install xclip
  863  cat ~/.ssh/id_rsa | xclip --selection clip
  864  cat ~/.ssh/id_rsa | xclip -selection clip
  865  cat ~/.ssh/id_rsa.pub | xclip -selection clip
  866  cd ~/jsteven5-dotfiles/
  867  git status
  868  git commit -am "Add SSH keys"
  869  git push
  870  cd -
  871  mv ~/.ssh ~/dev/ssh
  872  ln -s ~/dev/ssh ~/.ssh
  873  ls ~/.ssh
  874  ssh hwlosm
  875  cat ~/.ssh/id_rsa.pub | xclip -selection clip
  876  git status
  877  git remote remove origin
  878  git remote add origin git@kwvmxgit.ad.nerc.ac.uk:ODA/osm-tiles-docker.git
  879  git remote update
  880  git branch -av
  881  git checkout master
  882  git merge st_vincent
  883  git push origin master -u
  884  gvim README.md &
  885  git status
  886  git commit -am "Rename create_pngs to createpng"
  887  git push
  888  git branch -av
  889  git remote volcan01010 prune
  890  git remote prune volcan01010
  891  git branch -av
  892  git branch -D remotes/volcan01010/add-create-png
  893  git branch -D add-create-png st_vincent 
  894  git commit -am "Add original Github link to README.md"
  895  git push
  896  ls
  897  cat test_with_keyId.html 
  898  touch DELETE_ME
  899  git commit -am "Add empty DELETE_ME file"
  900  git add DELETE_ME 
  901  git commit -am "Add empty DELETE_ME file"
  902  git push
  903  docker login kwvmxgit.ad.nerc.ac.uk:4567
  904  docker build --help
  905  ls
  906  git remote update
  907  git pull
  908  git status
  909  git checkout -b test-ci
  910  git commit -am "Print variables pre build£
  911  "
  912  git push
  913  git push -u origin test-ci 
  914  git diff
  915  git commit -am "Added DOCKER_HOST to gitlab-ci"
  916  git push
  917  git diff
  918  git commit -am "Add docker-builder tag"
  919  git push
  920  git commit -am "Comment out before_script"
  921  git push
  922  ls
  923  cd jsteven5-dotfiles/
  924  ls
  925  git remote update
  926  git remote -v
  927  sudo apt install keepassx
  928  git status
  929  git diff README.md
  930  git commit -am "Update BGS keepass"
  931  git push
  932  ssh hwlosm
  933  ls -alh
  934  ls -ld /tmp
  935  sudo apt purge lightdm
  936  cd .local/share/gnome-shell/extensions/
  937  ls
  938  rm openweather-extension@jenslody.de/
  939  rm openweather-extension@jenslody.de/ -rf
  940  cd ~/dev/dataload-prototype/server-setup/roles/
  941  ls
  942  tree tw-dataload-user/
  943  cat tw-dataload-user/tasks/main.yml 
  944  cat tw-dataload-user/tasks/main.yml ls
  945  lc
  946  ls
  947  exit
  948  gnome-shell -r
  949  sudo gnome-shell -r
  950  cd ~/dev/SRTM/
  951  ls
  952  gdal_contour -i 10 -snodata 32767 -a height N13W060.hgt.zip N13W060.shp
  953  gdal_contour -i 10 -snodata 32767 -a height N13W060.hgt.zip N13W060_10.shp
  954  gdal_contour -i 10 -snodata 32767 -a height N13W060.hgt.zip N13W060c10.shp
  955  ls
  956  rm *.shx *.dbf *.prj
  957  ls
  958  gdal_contour -i 10 -snodata 32767 -a height N13W060.hgt.zip N13W060c10.shp
  959  gdal_contour -i 50 -snodata 32767 -a height N13W060.hgt.zip N13W060c50.shp
  960  gdal_contour -i 100 -snodata 32767 -a height N13W060.hgt.zip N13W060c100.shp
  961  gdal_contour -i 100 -snodata 32767 -a height N13W061.hgt.zip N13W061c100.shp
  962  gdal_contour -i 50 -snodata 32767 -a height N13W061.hgt.zip N13W061c50.shp
  963  gdal_contour -i 10 -snodata 32767 -a height N13W061.hgt.zip N13W061c10.shp
  964  pip instal elevation
  965  pip install elevation
  966  python -m elevation
  967  pip3 install elevation
  968  sudo pip install elevation
  969  sudo -H  pip install elevation
  970  eio
  971  eio selfcheck
  972  eio clip st_vincent_30m.tif --bounds -60.712 12.568 -60.705 13.626
  973  eio clip -o st_vincent_30m.tif --bounds -60.712 12.568 -60.705 13.626
  974  ls
  975  rm N13W06*
  976  ls
  977  eio clip -o st_vincent_30m.tif --bounds -61.52 12.55 -61.01 13.50
  978  gdal_contour --help
  979  history | grep gdal_contour
  980  man gdal_contour 
  981  gdal_calc.py --help
  982  gdal_edit.py --help
  983  gdal_calc.py -A st_vincent_30m.tif --outfile st_vincent_30m_nosea.tif --calc="A*(A>0)" --NoDataValue=0
  984  ls
  985  rm st_vincent_tiles.list 
  986  history > creating_contours.md
  987  gvim creating_contours.md 
  988  for h in 10 50 100; do gdal_contour -i ${h} -a height st_vincent_30m_nosea.tif st_vincent_contour_${h}.shp; done
  989  ls
  990  for h in 10 20 50 100; do gdal_contour -i ${h} -a height st_vincent_30m_nosea.tif st_vincent_contour_${h}.shp; done
  991  ls
  992  shp2pgsql --help
  993  man shp2pgsql 
  994  shp2pgsql -g way st_vincent_contour_10 contour | psql -h hwlosm -d gis -U www-data
  995  cd ~/dev/dataload-prototype/
  996  ls
  997  cd server-setup/
  998  ls
  999  cat ansible.cfg 
 1000  cat hosts
 1001  ls
 1002  cp ansible.cfg main.yml README.md hosts ~/osm-tiles-docker/ansible/
 1003  ls
 1004  ssh hwlosm
 1005  cd osm-tiles-docker/
 1006  git status
 1007  gvim .gitlab-ci.yml &
 1008  git status
 1009  git diff
 1010  git commit -am "Added docker login, stages and hello world"
 1011  git status
 1012  git push
 1013  git commit -am "Echo docker login credentials"
 1014  git push
 1015  history | grep login
 1016  ssh jsteven5@ssh.geos.ed.ac.uk
 1017  ping hwlosm
 1018  mkdir ansible
 1019  ls ~
 1020  ls
 1021  rm DELETE_ME 
 1022  cd ansible/
 1023  ls
 1024  sudo pip install ansible
 1025  pip install ansible
 1026  ls
 1027  ansible ping
 1028  ansible --help
 1029  ansible -i hwlosm -m ping
 1030  ansible hwlosm -m ping
 1031  ls
 1032  grep dataload_vault_password -r .
 1033  ansible hwlosm -m ping
 1034  ansible osm-tiles -m ping
 1035  ansible -i hosts -m ping
 1036  ansible --list-hosts
 1037  ansible --listhosts
 1038  ls
 1039  ls -l
 1040  chmod u-x ./*
 1041  ls -l
 1042  chmod g-x ./*
 1043  ls
 1044  chmod 644 ./*
 1045  ls
 1046  ls -l
 1047  cat hosts
 1048  ansible -i hwlosm -m ping
 1049  ansible all -m ping
 1050  ansible all -i hosts  -m ping
 1051  ls
 1052  ansible osm-tiles -i hosts  -m ping
 1053  mkdir -p deploy/tasks
 1054  tree
 1055  touch deploy/tasks/main.yml
 1056  ansible osm-tiles -i hosts main.yml 
 1057  ansible osm-tiles -i hosts
 1058  ansible osm-tiles -i hosts -m command echo hello
 1059  ansible osm-tiles -i hosts 
 1060  ansible-playbook osm-tiles -i hosts
 1061  ls
 1062  ansible-playbook main.yml -i hosts
 1063  git status
 1064  cd ..
 1065  lsd
 1066  git status
 1067  git add ansible/ DELETE_ME docker-compose.yml 
 1068  git add ansible/README.md 
 1069  git status
 1070  git commit -am "Add basic Ansible to deploy from dev laptop"
 1071  git push
 1072  ansible-playbook main.yml -i hosts
 1073  ls
 1074  cd ansible/
 1075  ansible-playbook main.yml -i hosts
 1076  cat hosts
 1077  cd ~/dev
 1078  ls
 1079  mdkir SRTM
 1080  mkdir SRTM
 1081  cd SRTM/
 1082  curl --help
 1083  vim st_vincent_tiles.list
 1084  cat st_vincent_tiles.list | curl
 1085  cat st_vincent_tiles.list | xargs curl
 1086  vim st_vincent_tiles.list
 1087  cat st_vincent_tiles.list | xargs curl
 1088  cat st_vincent_tiles.list | xargs -I {} curl --output $(basename {})
 1089  cat st_vincent_tiles.list | xargs wget
 1090  ls -l
 1091  ls -ls
 1092  ls -lsh
 1093  sudo apt install libreoffice
 1094  ls
 1095  cat st_vincent_tiles.list 
 1096  cd ~/jsteven5-dotfiles/
 1097  git status
 1098  git commit -am "Add Earthdata login"
 1099  git push
 1100  cd ~/osm-tiles-docker/
 1101  ls
 1102  psql -h hwlsom -p 5432 -d gis -U www-data
 1103  psql -h hwlosm -p 5432 -d gis -U www-data
 1104  psql -h hwlosm -p 5432 -d gis -U postgres
 1105  ifconfig
 1106  iwconfig
 1107  ipconfig
 1108  sudo apt-install ifconfig
 1109  sudo apt install ifconfig
 1110  ip addr show
 1111  ansible-playbook main.yml -i hosts
 1112  cd ansible/
 1113  ansible-playbook main.yml -i hosts
 1114  nmap hwlosm
 1115  psql -h hwlosm -U www-data -d gis
 1116  ssh hwlosm
 1117  cd dev/SRTM/
 1118  ls
 1119  rm st_vincent_srtm_30m.tif*
 1120  history | grep eio
 1121  eio --help
 1122  eio clean
 1123  eio distclean
 1124  ls
 1125  eio
 1126  eio clean
 1127  eio clip -o st_vincent_srtm_30m.tif --reference st_vincent_and_the_grenadines_land_mask.shp
 1128  history | grep eio
 1129  eio clip -o st_vincent_30m.tif --bounds -61.52 12.55 -61.01 13.50
 1130  ls
 1131  rm st_vincent_30m.tif 
 1132  eio clip -o st_vincent_srtm_30m.tif --reference st_vincent_and_the_grenadines_land_mask
 1133  eio clip -o st_vincent_srtm_30m.tif --reference st_vincent_and_the_grenadines_land_mask.shp
 1134  ls ~
 1135  rm ~/st_vincent_and_the_grenadines_admin_boundary.geojson 
 1136  cat ~/README.txt 
 1137  rm ~/README.txt
 1138  ls
 1139  eio clip -o st_vincent_srtm_30m.tif --reference st_vincent_and_the_grenadines_land_polygons.shp
 1140  eio clip --help
 1141  ogrinfo st_vincent_and_the_grenadines_land_polygons.shp
 1142  eio clip -o st_vincent_srtm_30m.tif --reference st_vincent_and_the_grenadines_land_mask.geojson 
 1143  ls
 1144  ls -sh
 1145  gdalinfo st_vincent_srtm_30m.tif 
 1146  less st_vincent_and_the_grenadines_land_mask.geojson 
 1147  rm st_vincent_and_the_grenadines.geojson 
 1148  ls
 1149  gvim creating_contours.md &
 1150  history | grep contour
 1151  gdal_contour -i 100 -a height st_vincent_srtm_30m.tif st_vincent_srtm_30m_contour_100.shp
 1152  gdal_contour -i 10 -a height st_vincent_srtm_30m.tif st_vincent_srtm_30m_contour_10.shp
 1153  gdal_contour --help
 1154  gdalinfo 
 1155  gdalinfo --formats
 1156  ogrinfo --formats
 1157  gdal_contour -i 10 -a height st_vincent_srtm_30m.tif -f GeoJSON st_vincent_srtm_30m_contour_10.geojson
 1158  rm st_vincent_srtm_30m_contour_10.geojson 
 1159  ogrmerge.py --help
 1160  ogrmerge.py -o st_vincent_srtm_30m_contour_10_clean.shp -single -field_strategy Intersection st_vincent_srtm_30m_contour_100.shp st_vincent_and_the_grenadines_land_mask.shp
 1161  ls -lrt
 1162  ogrmerge.py -o st_vincent_srtm_30m_contour_100_clean.shp -single -field_strategy Intersection st_vincent_srtm_30m_contour_100.shp st_vincent_and_the_grenadines_land_mask.shp
 1163  rm *clean*
 1164  gdal_contour -i 20 -a height st_vincent_srtm_30m.tif -f GeoJSON st_vincent_srtm_30m_contour_20.geojson
 1165  gdal_contour -i 50 -a height st_vincent_srtm_30m.tif -f GeoJSON st_vincent_srtm_30m_contour_50.geojson
 1166  ls
 1167  gvim creating_contours.md &
 1168  ls
 1169  ls -rt
 1170  history
 1171  history | grep shp2pgsql
 1172  shp2pgsql -p -I -g geom st_vincent_srtm_30m_contour_100.shp contour | psql -h hwlosm -d gis -U www-data
 1173  export PGPASSWORD=www-data
 1174  shp2pgsql -a -g geom st_vincent_srtm_30m_contour_100.shp contour | psql -h hwlosm -d gis -U www-data
 1175  shp2pgsql -a -g geom st_vincent_srtm_30m_contour_50.shp contour | psql -h hwlosm -d gis -U www-data
 1176  ls
 1177  shp2pgsql -a -g geom st_vincent_srtm_30m_contour_50_clean.shp contour | psql -h hwlosm -d gis -U www-data
 1178  shp2pgsql -p -I -g geom st_vincent_srtm_30m_contour_100_clean.shp contour | psql -h hwlosm -d gis -U www-data
 1179  shp2pgsql -a -g geom st_vincent_srtm_30m_contour_10_clean.shp contour | psql -h hwlosm -d gis -U www-data
 1180  shp2pgsql -a -g geom st_vincent_srtm_30m_contour_50_clean.shp contour | psql -h hwlosm -d gis -U www-data
 1181  shp2pgsql -a -g geom st_vincent_srtm_30m_contour_20_clean.shp contour | psql -h hwlosm -d gis -U www-data
 1182  shp2pgsql -a -g geom st_vincent_srtm_30m_contour_10_clean.shp contour | psql -h hwlosm -d gis -U www-data
 1183  ls
 1184  rm *_100_*
 1185  rm *_50_*
 1186  rm *_10_*
 1187  shp2pgsql -p -I -g geom st_vincent_srtm_30m_contour_10_clean.shp contour | psql -h hwlosm -d gis -U www-data
 1188  ls
 1189  rm st_vincent_srtm_30m_contour_100.*
 1190  rm st_vincent_srtm_30m_contour_20.*
 1191  rm st_vincent_srtm_30m_contour_50.*
 1192  ls
 1193  rm st_vincent_srtm_30m_contour_20*
 1194  ls
 1195  shp2pgsql -p -I -g geom st_vincent_srtm_30m_contour_10_clean.shp contour | psql -h hwlosm -d gis -U www-data
 1196  shp2pgsql -a -g geom st_vincent_srtm_30m_contour_10_clean.shp contour | psql -h hwlosm -d gis -U www-data
 1197  history
 1198  cd ~/osm-tiles-docker/
 1199  scp jostev@hwlosm:/users/jostev/style.xml build/style.xml
 1200  cat build/style.xml | grep 'Layer name'
 1201  ls
 1202  cp build/style.xml /tmp
 1203  scp jostev@hwlosm:/users/jostev/style.xml build/style.xml
 1204  git status
 1205  git diff
 1206  git commit -am "Fix synchronise step of Ansible deploy"
 1207  git add build/style.xml 
 1208  git commit -am "Add original style.xml file"
 1209  cp /tmp/style.xml build/style.xml 
 1210  git diff
 1211  git commit -am "Add Mapnik contour description to style.xml"
 1212  git status
 1213  git checkout -- docker-compose.yml
 1214  git push
 1215  git status
 1216  history | grep ansible
 1217  cd ansible/
 1218  ansible-playbook main.yml -i hosts
 1219  mkdir /tmp
 1220  mkdir /tmp/png
 1221  cd ~/jsteven5-dotfiles/
 1222  git status
 1223  git commit -am "Added sharefile"
 1224  git push
 1225  cd -
 1226  ls
 1227  cd dev
 1228  ls
 1229  ipython
 1230  which ipython
 1231  mkdir ~/venv
 1232  python3 -m venv ~/venv/mapnik
 1233  sudo apt install python3-dev python3-venv
 1234  python3 -m venv ~/venv/mapnik
 1235  source ~/venv/mapnik/bin/activate
 1236  pip install ipython mapnik
 1237  pip search mapnik
 1238  exit
 1239  ssh hwlosm
 1240  cd ~/osm-tiles-docker/
 1241  gvim README.md &
 1242  ls
 1243  cd ..
 1244  ls
 1245  git clone https://github.com/gravitystorm/openstreetmap-carto.git
 1246  cd osm-tiles-docker/
 1247  sudo apt search npm
 1248  sudo apt install npm
 1249  ls
 1250  npm --help
 1251  npm install -h
 1252  npm install carto@0.16.3
 1253  ls
 1254  ls node_modules/
 1255  cd node_modules/carto/
 1256  ls
 1257  cat README.md 
 1258  cd ..
 1259  ls
 1260  rm -rf node_modules/
 1261  ls -a
 1262  sudo npm install -g carto@0.16.3
 1263  git status
 1264  cd ../openstreetmap-carto/
 1265  git status
 1266  ls
 1267  carto project.mml > style.xml
 1268  ls -rtsh
 1269  vim USECASES.md 
 1270  vim ferry-routes.mss 
 1271  cd ..
 1272  ls
 1273  wget https://github.com/gravitystorm/openstreetmap-carto/archive/v3.0.1.tar.gz
 1274  ls
 1275  tar -xvzf openstreetmap-carto-v3.0.1
 1276  tar -xvzf v3.0.1.tar.gz 
 1277  ls
 1278  rm -rf v3.0.1.tar.gz 
 1279  cd openstreetmap-carto-3.0.1/
 1280  ls
 1281  vim style.mss 
 1282  cp ferry-routes.mss contours.mss
 1283  cd ..
 1284  ls
 1285  git clone https://github.com/cyberang3l/osm-maps.git
 1286  cd osm-maps/
 1287  ls
 1288  cd osm-bright-contours/
 1289  ls
 1290  cd osm-bright/
 1291  ls
 1292  cd ..
 1293  eog preview.png 
 1294  vim README.md 
 1295  ls
 1296  cp osm-bright/contour*.mss ~/osm-tiles-docker/build/ -v
 1297  cp ~/openstreetmap-carto-3.0.1/project.mml ~/osm-tiles-docker/build/ -v
 1298  cd ~/osm-tiles-docker/build/
 1299  git status
 1300  git add .
 1301  git status
 1302  meld ~/openstreetmap-carto-3.0.1/project.mml project.mml &
 1303  sudo apt-install meld
 1304  sudo apt install meld
 1305  meld ~/openstreetmap-carto-3.0.1/project.mml project.mml &
 1306  git status
 1307  git add .
 1308  git commit -m "Add files for contour rendering"
 1309  cd ../ansible/
 1310  ansible-playbook main.yml -i hosts
 1311  cd osm-tiles-docker/
 1312  ls
 1313  git status
 1314  git log --onelie
 1315  git log --oneline
 1316  git --version
 1317  ls
 1318  tree build/
 1319  gvim Dockerfile &
 1320  ansible-playbook main.yml -i hosts --tags just-copy
 1321  cd ansible/
 1322  ansible-playbook main.yml -i hosts --tags just-copy
 1323  ansible-playbook --help
 1324  /tag
 1325  ansible-playbook main.yml -i hosts -t just-copy
 1326  sudo npm install -g kosmtik
 1327  kosmtik 
 1328  git status
 1329  git diff
 1330  ansible-playbook main.yml -i hosts -t just-copy
 1331  sudo apt-get install autoconf apache2-dev libtool libxml2-dev libbz2-dev libgeos-dev libgeos++-dev libproj-dev gdal-bin libgdal1-dev libmapnik-dev mapnik-utils python-mapnik
 1332  apt search libgdal
 1333  sudo apt-get install autoconf apache2-dev libtool libxml2-dev libbz2-dev libgeos-dev libgeos++-dev libproj-dev gdal-bin libgdal-dev libmapnik-dev mapnik-utils python-mapnik
 1334  python
 1335  cd ~
 1336  ls
 1337  cd openstreetmap-carto
 1338  ls
 1339  git status
 1340  vim docker-compose.yml 
 1341  ln -s ~/data/pbf/central-america-latest.osm.pbf .
 1342  ls -l
 1343  docker-compose up import
 1344  ln -s ~/data/pbf/central-america-latest.osm.pbf data.osm.pbf
 1345  docker-compose up import
 1346  ls
 1347  rm central-america-latest.osm.pbf data.osm.pbf 
 1348  cp ~/data/pbf/central-america-latest.osm.pbf data.osm.pbf
 1349  docker-compose up import
 1350  export OSM2PGSQL_CACHE=2048
 1351  docker-compose up import
 1352  export OSM2PGSQL_CACHE=1024
 1353  free -h
 1354  PG_WORK_MEM=128MB PG_MAINTENANCE_WORK_MEM=2GB OSM2PGSQL_CACHE=2048 OSM2PGSQL_NUMPROC=4 OSM2PGSQL_DATAFILE=taiwan.osm.pbf docker-compose up import 
 1355  PG_WORK_MEM=128MB PG_MAINTENANCE_WORK_MEM=1.5GB OSM2PGSQL_CACHE=1024 OSM2PGSQL_NUMPROC=4 OSM2PGSQL_DATAFILE=data.osm.pbf docker-compose up import 
 1356  ssh hwlosm
 1357  cd dev/SRTM/
 1358  ls
 1359  eio --help
 1360  eio distclean
 1361  eio clean
 1362  eio distclean
 1363  ls ~/.cache/elevation/
 1364  history | grep eio
 1365  eio clip -o svg_srtm_30m_raw.tif --reference svg_land_mask_4326.geojson 
 1366  ls
 1367  rm svg_land_mask_4326.[spq]*
 1368  ls
 1369  rm svg_land_mask_4326.dbf 
 1370  ls
 1371  gvim creating_contours.md &
 1372  gdalwarp -cutline svg_land_mask_4326.geojson -crop_to_cutline svg_srtm_30m_raw.tif svg_srtm_30m.tif
 1373  ls
 1374  history | grep contour
 1375  gdal_contour -i 10 -a height svg_srtm_30m.tif svg_srtm_30m_contours_10m.geojson
 1376  ls -rt
 1377  rm svg_srtm_30m_contours_10m.geojson -rf
 1378  gdalwarp --help
 1379  man gdalwarp
 1380  docker ps
 1381  gdal_contour -i 10 -a height svg_srtm_30m.tif svg_srtm_30m_contours_10m
 1382  ls
 1383  ogr2ogr --formats
 1384  ogr2ogr --formats | grep tif
 1385  ogr2ogr --formats | grep -i tif
 1386  ogr2ogr --formats | grep -i json
 1387  ogr2ogr --hel
 1388  ogr2ogr -f GeoJSON  svg_srtm_30m_contours_10m.geojson svg_srtm_30m_contours_10m
 1389  ls -l
 1390  ls -lsh
 1391  rm svg_srtm_30m_contours_10m.geojson 
 1392  docker images
 1393  ls
 1394  scp /home/jostev/data/pbf/svg.data.osm jostev@hwlosm:/users/jostev/openstreetmap-carto/data.osm.pbf
 1395  cd ~/openstreetmap-carto
 1396  gvim README.md &
 1397  ls
 1398  scp /home/jostev/data/pbf/svg.osm.pbf hwlosm:/users/jostev/openstreetmap-carto/data.osm.pbf 
 1399  apt search osmconvert
 1400  sudo apt install osmctools
 1401  cd ~/data/pbf/
 1402  ls
 1403  rm svg.data.osm 
 1404  mv svg.osm.pbf svg.osm.xml
 1405  osmconvert --help
 1406* osmconvert svg.osm.xml --out-pbf > svg.osm.pbf 
 1407  scp /home/jostev/data/pbf/svg.osm.pbf hwlosm:/users/jostev/openstreetmap-carto/data.osm.pbf 
 1408  history | tail
 1409  gvim ~/dev/SRTM/creating_contours.md &
 1410  history | grep contour
 1411  cd ~/dev/SRTM/
 1412  ls
 1413  cd svg_srtm_30m_contours_10m/
 1414  ls
 1415  shp2pgsql -p -I -g way contour.shp contour | head
 1416  shp2pgsql -p -I -g way contour.shp contour | psql -h hwlosm -p 5432 -U postgres -d gis
 1417* shp2pgsql -p -I -g way contour.shp contour | psql -h hwlosm -p 5432 -U postgres -d postg
 1418  psql -h hwlosm -p 5432 -U postgres
 1421  history | xclip -selection clip
