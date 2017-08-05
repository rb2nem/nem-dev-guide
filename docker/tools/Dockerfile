from ubuntu:17.04

RUN apt update
RUN apt-get install -y  curl httpie supervisor jq mitmproxy tmux net-tools nano telnet nodejs npm tmux ruby ruby-dev rubygems python-pip libzmq3-dev
RUN pip install zerorpc
RUN npm install -g npm && \
    npm cache clean -f && \
    npm install -g n && \
    n latest
#RUN npm install -g ts-node typescript nem-library
RUN gem install rest-client
#RUN echo "en_US.UTF-8 UTF-8">> /etc/locale.gen
#RUN locale-gen
COPY ./container_files/supervisord.conf /etc/
COPY ./container_files/start.sh /usr/local/bin/start.sh
COPY ./container_files/etc/sudoers.d/nem /etc/sudoers.d/
RUN npm install -g ts-node typescript
RUN useradd -ms /bin/bash nem
USER nem
COPY ./container_files/bash_aliases /home/nem/.bash_aliases
# nem-sdk can only be installed locally. It is installed in /home/nem so repl.js needs to be there too
COPY ./container_files/repl.js /home/nem
RUN cd /home/nem && npm install nem-sdk sockjs-client stompjs zerorpc ts-node typescript nem-library
RUN echo cd >> $HOME/.bashrc
USER root
RUN apt install sudo
ENTRYPOINT ["/usr/local/bin/start.sh"]
