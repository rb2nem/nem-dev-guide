from ubuntu:16.04

RUN apt-get update
RUN apt-get install -y curl openjdk-8-jre-headless httpie supervisor
RUN curl -s https://packagecloud.io/install/repositories/rb2nem/nis/script.deb.sh |  bash
RUN apt-get install nem-nis
RUN apt-get install jq
COPY ./container_files/supervisord.conf /etc/
COPY ./container_files/start.sh /usr/local/bin/start.sh
ENTRYPOINT ["/usr/local/bin/start.sh"]
