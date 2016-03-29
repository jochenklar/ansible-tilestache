#/bin/bash
if [ -z "$1" ]; then
    echo "Usage: ./install_postgis_db.sh DBNAME FILENAME"
    exit 1;
else
    DBNAME=$1
fi
if [ -z "$2" ]; then
    echo "Usage: ./install_postgis_db.sh DBNAME FILENAME"
    exit 1;
else
    FILENAME=$2
fi

createdb -E UTF8 -O gis $DBNAME

{% if ansible_distribution == "Ubuntu" %}
psql $DBNAME -f /usr/share/postgresql/9.3/contrib/postgis-2.1/postgis.sql
psql $DBNAME -f /usr/share/postgresql/9.3/contrib/postgis-2.1/spatial_ref_sys.sql
{% else %}
psql $DBNAME -f /usr/share/postgresql/9.4/contrib/postgis-2.1/postgis.sql
psql $DBNAME -f /usr/share/postgresql/9.4/contrib/postgis-2.1/spatial_ref_sys.sql
{% endif %}

psql $DBNAME -c "ALTER TABLE geography_columns OWNER TO gis"
psql $DBNAME -c "ALTER TABLE geometry_columns OWNER TO gis"
psql $DBNAME -c "ALTER TABLE spatial_ref_sys OWNER TO gis"
