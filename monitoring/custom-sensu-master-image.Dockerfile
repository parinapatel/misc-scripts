FROM sstarcher/sensu
LABEL maintainers "parin.patel@aunalytics.com"
RUN sensu-install -p slack 