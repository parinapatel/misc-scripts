FROM ubuntu:latest
LABEL "MANTAINER"="Parin Pate parin.patel@aunalytics.com"
RUN apt update && apt install -y wget cron git && apt clean
RUN wget https://releases.rancher.com/cli/v0.6.5/rancher-linux-amd64-v0.6.5.tar.gz \
   && tar xvf rancher-linux-amd64-v0.6.5.tar.gz \
   && mv ./rancher-v0.6.5/rancher /usr/bin/rancher \
   && chmod +x /usr/bin/rancher
COPY rancher_backup.sh /root/rancher_backup.sh
RUN chmod +x /root/rancher_backup.sh && \
    touch /var/log/rancher_backup.log &&\
    ln -s /root/rancher_backup.sh /etc/cron.daily/rancher_backup.sh
CMD tail -f /var/log/rancher_backup.log
