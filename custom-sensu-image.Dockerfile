FROM sstarcher/sensu
LABEL maintainers "parin.patel@aunalytics.com"
RUN sensu-install -p memory-checks && sensu-install -p cpu-checks && sensu-install -p process-checks && sensu-install -p disk-checks network-checks && sensu-install -p slack && sensu-install -p network-checks && sensu-install -p vmstats && sensu-install -p docker && sensu-install -p mongodb
