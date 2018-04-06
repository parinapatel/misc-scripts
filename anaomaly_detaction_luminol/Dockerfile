FROM python:3-slim
LABEL MAINTAINER=parin.patel@aunalytics.com
RUN pip install --no-cache-dir luminol requests
COPY $PWD /root/
CMD bash /root/run.sh
