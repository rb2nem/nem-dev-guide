from ubuntu:17.04

RUN apt update
RUN apt-get install -y  curl httpie supervisor jq mitmproxy tmux net-tools nano telnet nodejs npm tmux
RUN npm install -g npm && \
    npm cache clean -f && \
    npm install -g n && \
    n stable
RUN npm install nem-sdk
#RUN echo "en_US.UTF-8 UTF-8">> /etc/locale.gen
#RUN locale-gen
COPY ./container_files/supervisord.conf /etc/
COPY ./container_files/start.sh /usr/local/bin/start.sh
COPY ./container_files/bash_aliases /root/.bash_aliases
COPY ./container_files/repl.js /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/start.sh"]
