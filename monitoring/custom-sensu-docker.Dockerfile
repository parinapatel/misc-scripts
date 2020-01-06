FROM centos:7
LABEL maintainers "parin.patel@aunalytics.com"
RUN yum install -y conntrack-tools nc && yum clean all &&  rm -rf /var/cache/yum
COPY network_connection.sh /root/network_connection.sh
# RUN chmod +x /root/network_connection.sh
CMD ["bash","/root/network_connection.sh"]