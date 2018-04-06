FROM sstarcher/sensu
LABEL maintainers "parin.patel@aunalytics.com"
#RUN echo "deb http://old-releases.ubuntu.com/ubuntu/ zesty main restricted universe multiverse" > /etc/apt/sources.list
RUN apt update && apt install -y jq && sensu-install -p haproxy
#RUN sensu-install -p memory-checks && sensu-install -p cpu-checks && sensu-install -p process-checks && sensu-install -p disk-checks network-checks && sensu-install -p slack && sensu-install -p network-checks && sensu-install -p vmstats && sensu-install -p docker
#docker run -d  -e REDIS_HOST="sensu.aunalytics.com" -e REDIS_PORT=6379 -e REDIS_AUTO_RECONNECT=true -e CLIENT_NAME=mongoprod -e CLIENT_ADDRESS=10.10.3.26 -e CLIENT_SUBSCRIPTIONS=host HOST_DEV_DIR="/host_dev" -e HOST_PROC_DIR="/host_proc" -e HOST_SYS_DIR="/host_sys" -v /dev:/host_dev/:ro -v /proc:/host_proc/:ro -v /sys:/host_sys/:ro --hostname="aunsight2-mongo.aunalytics.com" --name mongo-sensu-monitor registry.aunalytics.com:5000/sensu:mongo client
