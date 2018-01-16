FROM centos
LABEL maintainers "parin.patel@aunalytics.com"
WORKDIR /opt/pagerduty
RUN git clone https://github.com/PagerDuty/incident-response-docs.git
RUN yum install -y python python-pip && pip install mkdocs==0.15.3 mkdocs-material==0.2.4
CMD ["mkdocs","serve"] 
