from ubuntu:16.10

RUN apt update
RUN apt-get install -y apt-transport-https curl openjdk-8-jre-headless httpie supervisor jq net-tools nano less telnet
RUN curl  https://rb2nem.github.io/nem-nis-apt/pub.key | apt-key add -
RUN echo "deb https://rb2nem.github.io/nem-nis-apt/ xenial main" > /etc/apt/sources.list.d/nem-nis.list
RUN apt update
RUN apt-get install -y nem-nis
COPY ./container_files/supervisord.conf /etc/
COPY ./container_files/start.sh /usr/local/bin/start.sh
COPY ./container_files/repl.js /usr/local/bin/
COPY ./container_files/bash_aliases /root/.bash_aliases
ENTRYPOINT ["/usr/local/bin/start.sh"]
