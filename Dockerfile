FROM ubuntu:18.04

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

ARG NODE_MAJOR=12.16.1
ENV NVM_DIR=/usr/local/nvm
ENV NODE_VERSION=${NODE_MAJOR}

RUN \
    mkdir -p $NVM_DIR && wget -O- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash - && \
    source $NVM_DIR/nvm.sh && \
    nvm install $NODE_VERSION && \
    nvm use $NODE_VERSION

ENV NODE_PATH=$NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH=$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN \
    env && \
    npm install -g gitbook-cli && \
    gitbook ls-remote && \
    gitbook ls

RUN \
    gitbook fetch 2.6.9 && \
    gitbook ls

RUN \
    gitbook fetch 2.0.4 && \
    gitbook ls

RUN \
    find /root/.gitbook -name graceful-fs | xargs rm -rf && \
    find /root/.npm -name graceful-fs | xargs rm -rf && \
    find /tmp -name graceful-fs | xargs rm -rf && \
    npm install graceful-fs -g

WORKDIR /gitbook
#CMD ["gitbook", "help"]
CMD ["/bin/bash"]
