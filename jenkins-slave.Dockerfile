From  jenkins/ssh-slave
USER root
RUN wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 && \
   mv jq-linux64 jq && \
   chmod +x jq && cp jq /usr/bin

RUN curl -fsSLO https://get.docker.com/builds/Linux/x86_64/docker-17.04.0-ce.tgz \
  && tar xzvf docker-17.04.0-ce.tgz \
  && mv docker/docker /usr/local/bin \
  && rm -r docker docker-17.04.0-ce.tgz
RUN apt update && apt install -qqy npm && \
curl -sL https://deb.nodesource.com/setup_6.x |bash - && \
apt-get install -y nodejs
USER jenkins
