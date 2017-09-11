FROM ubuntu:xenial-20170802

ENV DEBIAN_FRONTEND=noninteractive
RUN sed -i.bak -e "s%http://archive.ubuntu.com/ubuntu/%http://ftp.jaist.ac.jp/pub/Linux/ubuntu/%g" /etc/apt/sources.list && \
    apt-get update -y && \
    apt-get dist-upgrade -y && \
    apt-get install -y \
    autoconf \
    build-essential \
    imagemagick \
    libbz2-dev \
    libcurl4-openssl-dev \
    libevent-dev \
    libffi-dev \
    libglib2.0-dev \
    libjpeg-dev \
    libmagickcore-dev \
    libmagickwand-dev \
    libmysqlclient-dev \
    libncurses-dev \
    libpq-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    libxml2-dev \
    libxslt-dev \
    libyaml-dev \
    wget \
    zlib1g-dev \
    python-software-properties \
    software-properties-common \
    patchutils \
    curl \
    procps \
    language-pack-en \
  && rm -rf /var/lib/apt/lists/*

# Install git from launchpad maintain repo
RUN add-apt-repository ppa:git-core/ppa -y && apt-get update -y && apt-get install -y \
    git \
  && rm -rf /var/lib/apt/lists/*

# Add locales
RUN locale-gen en_US.UTF-8

# Set default locale
ENV LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8

RUN update-locale en_US.UTF-8

RUN mkdir /root/work
WORKDIR /root/work

# Set Git config
RUN git config --global diff.compactionHeuristic true

# Install Ruby to use ruby script in node. e.g.) to expand glob
ENV RUBY_MAJOR=2.4 \
    RUBY_VERSION=2.4.1

# some of ruby's build scripts are written in ruby
# we purge this later to make sure our final image uses what we just built
RUN apt-get update -y \
  && apt-get install -y bison ruby \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /usr/src/ruby \
  && curl -SL "http://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.bz2" \
    | tar -xjC /usr/src/ruby --strip-components=1 \
  && cd /usr/src/ruby \
  && autoconf \
  && ./configure --disable-install-doc \
  && make -j"$(nproc)" \
  && apt-get purge -y --auto-remove bison ruby \
  && make install \
  && rm -r /usr/src/ruby

ADD gemrc /usr/local/etc/
ENV GEM_HOME /usr/local/bundle
ENV PATH $GEM_HOME/bin:$PATH
RUN gem install bundler \
  && bundle config --global path "$GEM_HOME" \
  && bundle config --global bin "$GEM_HOME/bin"

# don't create ".bundle" in all our apps
ENV BUNDLE_APP_CONFIG $GEM_HOME
