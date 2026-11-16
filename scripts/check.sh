#!/bin/bash

P="hw3_test"
export PORT=8090

trap 'docker compose -p $P down -v' EXIT

docker compose -p $P up -d --build
sleep 3

R=$(curl -s -m 2 http://127.0.0.1:$PORT/)
echo "$R" | grep -q '"count": 0' || { echo "fail: count != 0"; exit 1; }

for i in 1 2 3; do curl -s -m 2 -X POST http://127.0.0.1:$PORT/increment > /dev/null; done

R=$(curl -s -m 2 http://127.0.0.1:$PORT/)
echo "$R" | grep -q '"count": 3' || { echo "fail: count != 3"; exit 1; }

docker compose -p $P up -d --force-recreate app
sleep 2
R=$(curl -s -m 2 http://127.0.0.1:$PORT/)
echo "$R" | grep -q '"count": 3' || { echo "fail: lost data"; exit 1; }

docker compose -p $P stop redis > /dev/null
sleep 1
C=$(curl -s -m 2 -o /dev/null -w "%{http_code}" http://127.0.0.1:$PORT/readyz)
[ "$C" = "503" ] || { echo "fail: readyz != 503"; exit 1; }

docker compose -p $P start redis > /dev/null
sleep 2
C=$(curl -s -m 2 -o /dev/null -w "%{http_code}" http://127.0.0.1:$PORT/readyz)
[ "$C" = "200" ] || { echo "fail: readyz != 200"; exit 1; }

docker compose -p $P stop app redis > /dev/null
docker compose -p $P up -d redis > /dev/null
sleep 1
ID=$(docker compose -p $P ps -q redis)
docker cp $ID:/data ./redis_backup > /dev/null
echo "ok"
