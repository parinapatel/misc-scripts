FROM ubuntu:latest
ADD https://artifacts.aunalytics.com/toolbelt/Toolbelt-latest/aunsight-toolbelt2-linux /usr/bin/au2 
COPY [ "run.sh", "process.sh", "/root/" ]
RUN chmod +x /root/*.sh && chmod +x /usr/bin/au2
CMD "/root/run.sh"