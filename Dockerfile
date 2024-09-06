FROM ubuntu:20.04

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y -q --no-install-recommends install \
    ca-certificates \
    wget \
    git \
    strace \
    calibre && \
    git config --global --add safe.directory /gitbook

ARG NODE_MAJOR=12
ENV NVM_DIR=/usr/local/nvm
ENV NODE_VERSION=${NODE_MAJOR}

RUN \
    mkdir -p $NVM_DIR && wget -O- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash - && \
    source $NVM_DIR/nvm.sh && \
    nvm install $NODE_VERSION && \
    nvm use $NODE_VERSION && \
    export FULL_VER=`nvm version $NODE_VERSION` && \
    /bin/bash -l -c 'echo "export NODE_PATH=$NVM_DIR/versions/node/$FULL_VER/lib/node_modules" >> /env' && \
    /bin/bash -l -c 'echo "export PATH=$NVM_DIR/versions/node/$FULL_VER/bin:$PATH" >> /env' && \
    cat /env

RUN \
    export $(cat /env | xargs) && \
    npm install -g gitbook-cli && \
    gitbook ls-remote && \
    gitbook ls

RUN \
    export $(cat /env | xargs) && \
    gitbook fetch 2.6.9 && \
    gitbook ls

ADD ./SDSM /gitbook

RUN \
    export $(cat /env | xargs) && \
    find /root/.gitbook -name graceful-fs | xargs rm -rf && \
    find /root/.npm -name graceful-fs | xargs rm -rf && \
    find /tmp -name graceful-fs | xargs rm -rf && \
    npm install graceful-fs -g

WORKDIR /gitbook

RUN \
    export $(cat /env | xargs) && \
    gitbook pdf .

#ADD ./entrypoint /
#RUN chmod +x /entrypoint
#CMD ["/entrypoint"]

CMD ["/bin/bash"]
