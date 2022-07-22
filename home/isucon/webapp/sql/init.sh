#!/bin/sh

set -ex
cd `dirname $0`

ISUCON_DB_HOST=${ISUCON_DB_HOST:-127.0.0.1}
ISUCON_DB_PORT=${ISUCON_DB_PORT:-3306}
ISUCON_DB_USER=${ISUCON_DB_USER:-isucon}
ISUCON_DB_PASSWORD=${ISUCON_DB_PASSWORD:-isucon}
ISUCON_DB_NAME=${ISUCON_DB_NAME:-isuports}

# MySQLを初期化
mysql -u"$ISUCON_DB_USER" \
		-p"$ISUCON_DB_PASSWORD" \
		--host "$ISUCON_DB_HOST" \
		--port "$ISUCON_DB_PORT" \
		"$ISUCON_DB_NAME" < init.sql

# SQLiteのデータベースを初期化
rm -f ../tenant_db/*.db
cp -r ../../initial_data/*.db ../tenant_db/

./sqlite3-to-sql ../tenant_db/1.db > 1.db.dump
cat 1.db.dump | grep 'INSERT INTO player_score' | sed 's/^.*VALUES\|;$/"/g' | xargs -n10000 | tr ' ' ',' | sed 's/^/INSERT INTO player_score VALUES /' | sed 's/$/;/' > insert1_player_score.sql
cat 1.db.dump | grep -v 'INSERT INTO player_score' > insert1.sql
mysql -u"$ISUCON_DB_USER" \
		-p"$ISUCON_DB_PASSWORD" \
		--host "$ISUCON_DB_HOST" \
		--port "$ISUCON_DB_PORT" \
		"$ISUCON_DB_NAME" < insert1.sql
mysql -u"$ISUCON_DB_USER" \
		-p"$ISUCON_DB_PASSWORD" \
		--host "$ISUCON_DB_HOST" \
		--port "$ISUCON_DB_PORT" \
		"$ISUCON_DB_NAME" < insert1_player_score.sql
mv ../tenant_db/1.db ./1.db
find ../tenant_db/ -name '*.db' | parallel --jobs 100 "./sqlite3-to-sql {} | mysql -u$ISUCON_DB_USER -p$ISUCON_DB_PASSWORD --host $ISUCON_DB_HOST --port $ISUCON_DB_PORT $ISUCON_DB_NAME"
mv ./1.db ../tenant_db/1.db
