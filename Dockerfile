FROM debian:latest

EXPOSE 8080 3000

ENV gotty_version=v1.0.1

ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm-256color

# make the "en_US.UTF-8" locale
RUN apt-get update -qq && \
    apt-get install -qq locales && \
    rm -rf /var/lib/apt/lists/* && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG=en_US.utf8

RUN apt-get update -qq && \
    apt-get install -qq \
        acl \
        bash-completion \
        curl \
        git \
        gpg \
        pwgen \
        nano \
        sudo \
        tmux \
        wget && \
    rm -rf /var/lib/apt/lists/*

# Install GoTTY
WORKDIR /tmp/gotty
RUN wget -q -O gotty.tar.gz https://github.com/yudai/gotty/releases/download/${gotty_version}/gotty_linux_amd64.tar.gz && \
    tar -xf gotty.tar.gz && \
    chmod +x gotty && \
    mv gotty /usr/local/bin/ && \
    rm -rf /tmp/gotty

VOLUME /userdata
COPY .gotty.default /tmp/

COPY ./docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["gotty", "/bin/login"]