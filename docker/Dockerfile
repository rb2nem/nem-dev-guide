from ubuntu:16.10

RUN apt update
RUN apt-get install -y curl openjdk-8-jre-headless httpie supervisor jq nodejs npm
RUN curl -s https://packagecloud.io/install/repositories/rb2nem/nis/script.deb.sh |  bash
RUN apt update
RUN apt-get install nem-nis=0.6.84
RUN npm install -g npm && \
    npm cache clean -f && \
    npm install -g n && \
    n stable
RUN npm install nem-sdk
COPY ./container_files/supervisord.conf /etc/
COPY ./container_files/start.sh /usr/local/bin/start.sh
COPY ./container_files/repl.js /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/start.sh"]
