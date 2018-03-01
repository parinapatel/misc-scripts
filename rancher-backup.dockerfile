FROM centos:7
LABEL "MANTAINER"="Parin Pate parin.patel@aunalytics.com"
RUN yum install -y cronie wget git
RUN wget https://releases.rancher.com/cli/v0.6.5/rancher-linux-amd64-v0.6.5.tar.gz \
   && tar xvf rancher-linux-amd64-v0.6.5.tar.gz \
   && mv ./rancher-v0.6.5/rancher /usr/bin/rancher \
   && chmod +x /usr/bin/rancher
ENV GIT_SSH_COMMAND "ssh -i /root/keys/git_id_rsa -F /dev/null"
COPY rancher_backup.sh /root/rancher_backup.sh
RUN chmod +x /root/rancher_backup.sh && \
    touch /etc/cron.d/cron_rancher &&\
    echo "0 0 * * * /root/rancher-backup.sh > /dev/stdout" > /etc/cron.d/cron_rancher
CMD ["crond"]
