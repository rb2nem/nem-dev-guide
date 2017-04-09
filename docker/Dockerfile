from ubuntu:16.10

RUN apt-get update
RUN apt-get install -y curl openjdk-8-jre-headless httpie supervisor jq
RUN curl -s https://packagecloud.io/install/repositories/rb2nem/nis/script.deb.sh |  bash
RUN apt-get install nem-nis=0.6.84
COPY ./container_files/supervisord.conf /etc/
COPY ./container_files/start.sh /usr/local/bin/start.sh
ENTRYPOINT ["/usr/local/bin/start.sh"]
