FROM sstarcher/sensu
LABEL maintainers "parin.patel@aunalytics.com"
RUN apt-get update && apt-get install -y build-essential wget apt-transport-https \
&& sensu-install -p slack \
&& sensu-install -p mailer \
&&  rm -rf /var/lib/apt/lists/* \
&& apt-get clean \
&& apt-get autoremove -y build-essential wget
