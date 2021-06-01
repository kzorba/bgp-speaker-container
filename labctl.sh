#!/bin/bash

case "$1" in
    start)
	echo "Starting eBGP speakers..."
	docker-compose up -d --remove-orphans
	echo "Done"
	echo "Initializing BGP peering"
	sleep 5
	echo "==> bgp-peer1: Feeding IPv4 prefixes"
	docker exec -ti bgp-peer1 /bin/bash -c "goBGPFeed.sh < /data/peer1_v4_prefixes.txt"
	echo "==> bgp-peer1: Feeding IPv6 prefixes"
	docker exec -ti bgp-peer1 /bin/bash -c "goBGPFeed.sh < /data/peer1_v6_prefixes.txt"
	echo "==> bgp-peer2: Feeding IPv4 prefixes"
	docker exec -ti bgp-peer2 /bin/bash -c "goBGPFeed.sh < /data/peer2_v4_prefixes.txt"
	echo "==> bgp-peer2: Feeding IPv6 prefixes"
	docker exec -ti bgp-peer2 /bin/bash -c "goBGPFeed.sh < /data/peer2_v6_prefixes.txt"
	echo "---------------------------------"
	echo "You can login to each container using the commands:"
	echo "> docker exec -ti bgp-peer1 /bin/bash"
	echo "> docker exec -ti bgp-peer2 /bin/bash"
	echo "In each container shell use: gobgp help"
	echo "---------------------------------"
    ;;
    stop)
	echo "Stopping eBGP speakers..."
	docker-compose down
	echo "Done"
    ;;
    restart)
    $0 stop
    $0 start
    ;;
    status)
       docker ps
	   echo "==> bgp-peer1: show neighbors"
       docker exec -ti bgp-peer1 /bin/bash -c "gobgp neighbor"
	   echo "==> bgp-peer2: show neighbors"
       docker exec -ti bgp-peer2 /bin/bash -c "gobgp neighbor"
    ;;
    refresh)
       echo "Refreshing docker containers..."
       docker-compose up -d --remove-orphans
       echo "Done"
    ;;
    *)
    echo "Usage: $0 {start|stop|restart|status|refresh}"
    exit 1
    ;;
esac

exit 0

