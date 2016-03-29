Usage
-----

First setup ansible to connect to the host. Then run the playbook.

```
ansible-playbook main.yml -l HOSTNAME
```

Download or copy osm dump to `/srv/gis/osm/`:

```
scp berlin-latest.osm.bz2 tiles.vm:/srv/gis/osm/berlin-latest.osm.pbf
```

Download or copy shapefiles to `/srv/gis/shp/`:

```
scp -r processed_p tiles.vm:/srv/gis/shp/processed_p
scp -r shoreline_300 tiles.vm:/srv/gis/shp/shoreline_300
scp -r ne_110m_admin_0_boundary_lines_land tiles.vm:/srv/gis/shp/ne_110m_admin_0_boundary_lines_land
```

Log into the machine setup the postgis database:

```
su - postgres
/srv/gis/bin/install_postgis_db.sh postgis_berlin
```

Ingest the OSM dump using `osm2pgsql`.

```
osm2pgsql -s -m -d postgis_berlin /srv/gis/osm/berlin-latest.osm.pbf
```

Clone the bbs theme:

```
git clone https://github.com/BuergerbautStadt/bbs-mapnik /srv/gis/mapnik/bbs
```

Force ownership for `/srv/gis`:

```
chown -R gis:gis /srv/gis
```

Setup VirtualHost in `/etc/apache2/sites-available/000-default.conf`:

```
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined

    WSGIDaemonProcess tilestache user=gis group=gis processes=2
    WSGIProcessGroup tilestache
    WSGIScriptAlias / /srv/gis/tilestache/wsgi.py

    <Directory /srv/gis/tilestache/>
        <Files wsgi.py>
            Require all granted
        </Files>
    </Directory>
</VirtualHost>
```

Setup TileStache in `/srv/gis/tilestache/tilestache.cfg`:

```
{
  "cache": {
    "name": "Multi",
    "tiers": [
      {
        "name": "Memcache"
      },
      {
        "name": "Disk",
        "path": "/srv/gis/cache"
      }
    ]
  },
  "layers": {
    "bbs-germany": {
      "provider": {
        "name": "mapnik",
        "mapfile": "/srv/gis/mapnik/bbs/germany.xml"
      },
      "preview": {
        "lat": 52.518611,
        "lon": 13.408333,
        "zoom": 15
      }
    }
  }
}
```

or for development:

```
{
  "cache": {
    "name": "Test"
  },
  "layers": {
    "bbs-germany": {
      "provider": {
        "name": "mapnik",
        "mapfile": "/srv/gis/mapnik/bbs/germany.xml"
      },
      "preview": {
        "lat": 52.518611,
        "lon": 13.408333,
        "zoom": 15
      }
    }
  }
}

```

Restart Apache.
