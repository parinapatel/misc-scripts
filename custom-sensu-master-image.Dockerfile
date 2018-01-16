FROM sstarcher/sensu
LABEL maintainers "parin.patel@aunalytics.com"
RUN apt-get update && apt-get install -y build-essential wget apt-transport-https \
&& sh -c 'echo "deb https://packages.pagerduty.com/pdagent deb/" >/etc/apt/sources.list.d/pdagent.list' \
&&  apt-get update \
&& apt-get install -y --allow-unauthenticated pdagent pdagent-integrations \
&& sensu-install -p slack \
&& sensu-install -p mailer \
&&  rm -rf /var/lib/apt/lists/*
