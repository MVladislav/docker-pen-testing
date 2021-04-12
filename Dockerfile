# FROM ubuntu:20.04
FROM ghcr.io/linuxserver/baseimage-ubuntu:bionic

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="MVladislav version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="MVladislav"

#############################
# DEFAULTS
#############################

# Environment Variables
ENV HOME /root
ENV DEBIAN_FRONTEND=noninteractive

# Working Directory
WORKDIR /root
RUN \
  mkdir ${HOME}/toolkit &&\
  mkdir ${HOME}/wordlists

#############################
# INIT UPDATE/UPGRADE
#############################

# Update
RUN \
  apt-get update &&\
  apt-get upgrade -y

#############################
# DEPENDENCIES
#############################

# Install Essentials
RUN \
  apt-get install -y --no-install-recommends \
  build-essential \
  tmux \
  gcc \
  iputils-ping\
  git \
  vim \
  wget \
  awscli \
  tzdata \
  curl \
  make \
  cmake \
  nmap \
  whois \
  python3 \
  python3-pip \
  # perl-base \
  nikto \
  dnsutils \
  net-tools \
  zsh \
  nano \
  lsb-release \
  jq \
  packer \
  # doctl \
  rsync \
  libnotify-bin \
  unzip \
  # for killall
  psmisc

# Install Extra Essentials
RUN \
  apt-get install -y --no-install-recommends \
  sqlmap \
  dirb \
  cpanminus \
  libldns-dev \
  libcurl4-openssl-dev \
  libxml2 \
  libxml2-dev \
  libxslt1-dev \
  python3-setuptools \
  python3-protobuf \
  python3-requests \
  python3-numpy \
  python3-serial \
  python3-usb \
  python3-dev \
  python3-websockets \
  python3-pycurl \
  python3-dnspython \
  ruby-dev \
  libgmp-dev \
  zlib1g-dev \
  libpcap-dev \
  libwww-perl \
  hydra \
  dnsrecon \
  powerline \
  fonts-powerline \
  # xsltproc for nmap to html
  xsltproc \
  # geo ip lookip "geoiplookup <ip>"
  geoip-bin


# Install more Tools
RUN \
  apt-get install -y --no-install-recommends \
  sqlmap
# dnsenum \
# wfuzz \
# knock \
# massdns \
# masscan \
# theharvester \
# joomscan \
# wpcscan

#############################
# ...
#############################

# tzdata
RUN ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime &&\
  dpkg-reconfigure --frontend noninteractive tzdata

#############################
# LEGACY
#############################


RUN \
  apt-get install -y --no-install-recommends \
  python2.7 \
  python2.7-dev

# PIP 2.7
RUN \
  cd ${HOME}/toolkit &&\
  curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py &&\
  /usr/bin/python2.7 get-pip.py &&\
  /usr/bin/python2.7 -m pip install --upgrade pip
# update python2
RUN pip install --upgrade setuptools
RUN pip install --upgrade pip

#############################
# PIP PYTHON
#############################

# update python3
# RUN pip3 install --upgrade setuptools
# RUN pip3 install --upgrade pip

# wfuzz
RUN pip install wfuzz

# s3recon
RUN pip3 install pyyaml pymongo requests s3recon

# fierce
RUN pip3 install fierce

#############################
# GO
#############################

# go
RUN cd /opt &&\
  wget https://golang.org/dl/go1.16.linux-amd64.tar.gz -O go.tar.gz &&\
  tar -xvf go.tar.gz &&\
  rm -rf /opt/go.tar.gz &&\
  mv go /usr/local
ENV GOROOT /usr/local/go
ENV GOPATH /root/go
ENV PATH ${GOPATH}/bin:${GOROOT}/bin:${PATH}

# # subfinder
# RUN GO111MODULE=on  &&\
#   go get -u -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder

# # amass
# RUN export GO111MODULE=on &&\
#   go get -v github.com/OWASP/Amass/v3/...

# gobuster
RUN cd ${HOME}/toolkit &&\
  git clone https://github.com/OJ/gobuster.git &&\
  cd gobuster &&\
  go get && go install

#############################
# GITHUB
#############################

# seclists
RUN cd ${HOME}/wordlists &&\
  git clone --depth 1 https://github.com/danielmiessler/SecLists.git

# zsh
RUN \
  git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh &&\
  cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc &&\
  chsh -s /bin/zsh &&\
  chsh -s /bin/zsh root &&\
  git clone https://github.com/denysdovhan/spaceship-prompt.git "$HOME/.oh-my-zsh/themes/spaceship.zsh-theme" --depth 1 &&\
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.zsh-syntax-highlighting" --depth 1
# agnoster
# spaceship
RUN \
  # echo "source $HOME/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> "$HOME/.zshrc" &&\
  # grep -q '^ZSH_THEME=' "$HOME/.zshrc" && sed -i 's/^ZSH_THEME=.*/ZSH_THEME="spaceship"/' "$HOME/.zshrc" || echo 'ZSH_THEME="spaceship"' >> "$HOME/.zshrc" &&\
  grep -q '^plugins=' "$HOME/.zshrc" && sed -i 's/^plugins=.*/plugins=\(git vscode ubuntu colored-man-pages command-not-found cp docker fd  gitignore history man nmap vim-interaction python pip docker-compose\)/' "$HOME/.zshrc" || echo 'plugins=(git vscode ubuntu colored-man-pages command-not-found cp docker fd  gitignore history man nmap vim-interaction python pip docker-compose)' >> "$HOME/.zshrc"

# ..............................................................................

# knock
RUN pip3 install pyqt5==5.14.0
RUN cd ${HOME}/toolkit &&\
  git clone https://github.com/guelfoweb/knock.git &&\
  cd knock &&\
  pip3 install -r requirements.txt &&\
  chmod +x setup.py &&\
  python3 setup.py install

# wafw00f
RUN cd ${HOME}/toolkit &&\
  git clone https://github.com/enablesecurity/wafw00f.git &&\
  cd wafw00f &&\
  chmod +x setup.py &&\
  python3 setup.py install

# altdns
RUN cd ${HOME}/toolkit &&\
  git clone https://github.com/infosec-au/altdns.git &&\
  cd altdns &&\
  pip3 install -r requirements.txt &&\
  chmod +x setup.py &&\
  python3 setup.py install

# ..............................................................................

# wpscan
RUN cd ${HOME}/toolkit &&\
  git clone https://github.com/wpscanteam/wpscan.git &&\
  cd wpscan/ &&\
  gem install bundler && bundle install --without test &&\
  gem install wpscan

# # axiom
# RUN cd ${HOME}/toolkit &&\
#   rm -rf .axiom/ &&\
#   git clone https://github.com/pry0cc/axiom .axiom/  &&\
#   cd .axiom &&\
#   chmod +x ./interact/axiom-configure
# #  &&\
# # ./interact/axiom-configure

# ..............................................................................

# dnsenum
RUN cd ${HOME}/toolkit &&\
  git clone https://github.com/fwaeytens/dnsenum.git &&\
  cd dnsenum/ &&\
  chmod +x dnsenum.pl &&\
  ln -sf ${HOME}/toolkit/dnsenum/dnsenum.pl /usr/bin/dnsenum &&\
  cpanm String::Random &&\
  cpanm Net::IP &&\
  cpanm Net::DNS &&\
  cpanm Net::Netmask &&\
  cpanm XML::Writer

# dotdotpwn
RUN cd ${HOME}/toolkit &&\
  cpanm Net::FTP &&\
  cpanm Time::HiRes &&\
  cpanm HTTP::Lite &&\
  cpanm Switch &&\
  cpanm Socket &&\
  cpanm IO::Socket &&\
  cpanm Getopt::Std &&\
  cpanm TFTP &&\
  git clone https://github.com/AlexisAhmed/dotdotpwn.git &&\
  cd dotdotpwn &&\
  chmod +x dotdotpwn.pl &&\
  ln -sf ${HOME}/toolkit/dotdotpwn/dotdotpwn.pl /usr/local/bin/dotdotpwn

# ..............................................................................

# fzf
RUN cd ${HOME}/toolkit &&\
  git clone --depth 1 https://github.com/junegunn/fzf.git &&\
  cd fzf/ &&\
  ./install

# Sublist3r
RUN cd ${HOME}/toolkit &&\
  git clone https://github.com/aboul3la/Sublist3r.git &&\
  cd Sublist3r/ &&\
  pip3 install -r requirements.txt &&\
  ln -sf ${HOME}/toolkit/Sublist3r/sublist3r.py /usr/local/bin/sublist3r

# massdns
RUN cd ${HOME}/toolkit &&\
  git clone https://github.com/blechschmidt/massdns.git &&\
  cd massdns/ &&\
  make &&\
  ln -sf ${HOME}/toolkit/massdns/bin/massdns /usr/local/bin/massdns

# commix
RUN cd ${HOME}/toolkit &&\
  git clone https://github.com/commixproject/commix.git &&\
  cd commix &&\
  chmod +x commix.py &&\
  ln -sf ${HOME}/toolkit/commix/commix.py /usr/local/bin/commix

# masscan
RUN cd ${HOME}/toolkit &&\
  git clone https://github.com/robertdavidgraham/masscan.git &&\
  cd masscan &&\
  make &&\
  ln -sf ${HOME}/toolkit/masscan/bin/masscan /usr/local/bin/masscan

# teh_s3_bucketeers
RUN cd ${HOME}/toolkit &&\
  git clone https://github.com/tomdev/teh_s3_bucketeers.git &&\
  cd teh_s3_bucketeers &&\
  chmod +x bucketeer.sh &&\
  ln -sf ${HOME}/toolkit/teh_s3_bucketeers/bucketeer.sh /usr/local/bin/bucketeer

# Recon-ng
RUN cd ${HOME}/toolkit &&\
  git clone https://github.com/lanmaster53/recon-ng.git &&\
  cd recon-ng &&\
  pip3 install -r REQUIREMENTS &&\
  chmod +x recon-ng &&\
  ln -sf ${HOME}/toolkit/recon-ng/recon-ng /usr/local/bin/recon-ng

# XSStrike
RUN cd ${HOME}/toolkit &&\
  git clone https://github.com/s0md3v/XSStrike.git &&\
  cd XSStrike &&\
  pip3 install -r requirements.txt &&\
  chmod +x xsstrike.py &&\
  ln -sf ${HOME}/toolkit/XSStrike/xsstrike.py /usr/local/bin/xsstrike

# CloudFlair
RUN cd ${HOME}/toolkit &&\
  git clone https://github.com/christophetd/CloudFlair.git &&\
  cd CloudFlair &&\
  pip3 install -r requirements.txt &&\
  chmod +x cloudflair.py &&\
  ln -sf ${HOME}/toolkit/CloudFlair/cloudflair.py /usr/local/bin/cloudflair

# joomscan
RUN cd ${HOME}/toolkit &&\
  git clone https://github.com/rezasp/joomscan.git &&\
  cd joomscan/ &&\
  chmod +x joomscan.pl &&\
  ln -sf ${HOME}/toolkit/joomscan/joomscan.pl /usr/local/bin/joomscan

# virtual-host-discovery
RUN cd ${HOME}/toolkit &&\
  git clone https://github.com/AlexisAhmed/virtual-host-discovery.git &&\
  cd virtual-host-discovery &&\
  chmod +x scan.rb &&\
  ln -sf ${HOME}/toolkit/virtual-host-discovery/scan.rb /usr/local/bin/virtual-host-discovery

# bucket_finder
RUN cd ${HOME}/toolkit &&\
  git clone https://github.com/AlexisAhmed/bucket_finder.git &&\
  cd bucket_finder &&\
  chmod +x bucket_finder.rb &&\
  ln -sf ${HOME}/toolkit/bucket_finder/bucket_finder.rb /usr/local/bin/bucket_finder

# dirsearch
RUN cd ${HOME}/toolkit &&\
  git clone https://github.com/AlexisAhmed/dirsearch.git &&\
  cd dirsearch &&\
  chmod +x dirsearch.py &&\
  ln -sf ${HOME}/toolkit/dirsearch/dirsearch.py /usr/local/bin/dirsearch

# whatweb
RUN cd ${HOME}/toolkit &&\
  git clone https://github.com/urbanadventurer/WhatWeb.git &&\
  cd WhatWeb &&\
  chmod +x whatweb &&\
  ln -sf ${HOME}/toolkit/WhatWeb/whatweb /usr/local/bin/whatweb

# censys-subdomain-finder
ENV CENSYS_API_ID $CENSYS_API_ID
ENV CENSYS_API_SECRET $CENSYS_API_SECRET
RUN cd ${HOME}/toolkit &&\
  git clone https://github.com/christophetd/censys-subdomain-finder.git &&\
  cd censys-subdomain-finder &&\
  chmod +x censys_subdomain_finder.py &&\
  ln -sf ${HOME}/toolkit/censys-subdomain-finder/censys_subdomain_finder.py /usr/local/bin/censys_subdomain_finder

# # SimplyEmail (#TODO: always in ptf, see below)
# RUN cd ${HOME}/toolkit &&\
#   git clone -b master https://github.com/SimplySecurity/SimplyEmail.git &&\
#   cd SimplyEmail &&\
#   pip2 install -r ./setup/requirments.txt &&\
#   # pip2 install configparser &&\
#   chmod +x SimplyEmail.py &&\
#   # chmod +x ./setup/setup.sh &&\
#   # ./setup/setup.sh &&\
#   ln -sf ${HOME}/toolkit/SimplyEmail/SimplyEmail.py /usr/local/bin/SimplyEmail

# https://github.com/nettitude/Prowl
RUN cd ${HOME}/toolkit &&\
  git clone https://github.com/nettitude/Prowl.git &&\
  cd Prowl &&\
  pip2 install -r ./requirements.txt &&\
  chmod +x prowl.py &&\
  ln -sf ${HOME}/toolkit/Prowl/prowl.py /usr/local/bin/prowl

# sslScrape
RUN cd ${HOME}/toolkit &&\
  git clone https://github.com/cheetz/sslScrape.git &&\
  cd sslScrape &&\
  pip install ndg-httpsclient &&\
  pip install python-masscan &&\
  chmod +x sslScrape.py &&\
  ln -sf ${HOME}/toolkit/sslScrape/sslScrape.py /usr/local/bin/sslScrape

# tlsScrape
RUN cd ${HOME}/toolkit &&\
  mkdir tlsScrape && cd tlsScrape &&\
  wget https://gist.githubusercontent.com/mzet-/4c29137ab6b642f8f84d0fcd2f14403b/raw/409c7c5e724dfe4d8d7085cff5f9a6f8c70919e1/tlsScrape.sh -O tlsScrape.sh &&\
  chmod +x tlsScrape.sh &&\
  ln -sf ${HOME}/toolkit/tlsScrape/tlsScrape.sh /usr/local/bin/tlsScrape

# sherlock
RUN cd ${HOME}/toolkit &&\
  git clone https://github.com/sherlock-project/sherlock.git &&\
  cd sherlock &&\
  pip3 install -r requirements.txt &&\
  chmod +x sherlock/sherlock.py &&\
  ln -sf ${HOME}/toolkit/sherlock/sherlock/sherlock.py /usr/local/bin/sherlock

# ansifilter
RUN cd ${HOME}/toolkit &&\
  git clone https://gitlab.com/saalen/ansifilter.git &&\
  cd ansifilter &&\
  make &&\
  make install

# kiterunner
# routes-large.json.tar.gz => routes-large.json
# routes-large.kite.tar.gz => routes-large.kite
RUN cd ${HOME}/toolkit &&\
  git clone https://github.com/assetnote/kiterunner.git &&\
  cd kiterunner &&\
  make build &&\
  ln -s $(pwd)/dist/kr /usr/local/bin/kr &&\
  # wget https://wordlists-cdn.assetnote.io/rawdata/kiterunner/routes-large.json.tar.gz &&\
  wget https://wordlists-cdn.assetnote.io/data/kiterunner/routes-large.kite.tar.gz &&\
  # tar -xzf routes-large.json.tar.gz &&\
  # kr kb compile routes-large.json routes.kite &&\
  # rm routes-large.json &&\
  tar -xzf routes-large.kite.tar.gz &&\
  mv routes-large.kite routes.kite


# # theHarvester (#TODO: always in ptf, see below)
# RUN cd ${HOME}/toolkit &&\
#   git clone https://github.com/AlexisAhmed/theHarvester.git &&\
#   cd theHarvester &&\
#   pip2 install -r requirements.txt &&\
#   chmod +x theHarvester.py &&\
#   ln -sf ${HOME}/toolkit/theHarvester/theHarvester.py /usr/local/bin/theHarvester

#############################
# BIG PAKET PTF
#############################

# ptf
RUN cd ${HOME}/toolkit &&\
  git clone https://github.com/trustedsec/ptf &&\
  cd ptf &&\
  pip3 install -r requirements.txt &&\
  pip3 install aiodns aiohttp aiosqlite plotly aiomultiprocess &&\
  chmod u+x ptf && ./ptf &&\
  echo -en "use modules/exploitation/install_update_all\nyes\nuse modules/intelligence-gathering/install_update_all\nyes\nuse modules/post-exploitation/install_update_all\nyes\nuse modules/powershell/install_update_all\nyes\nuse modules/vulnerability-analysis/install_update_all\nyes\n" | python3 ptf
# use modules/exploitation/install_update_all &&\
# use modules/intelligence-gathering/install_update_all &&\
# use modules/post-exploitation/install_update_all &&\
# use modules/powershell/install_update_all &&\
# use modules/vulnerability-analysis/install_update_all

#############################
# Trace route ...
#############################

# # dublin-traceroute
# RUN apt-get update &&\
#   apt-get install -y --no-install-recommends \
#   dublin-traceroute\
#   graphviz\
#   graphviz-dev\
#   libgraphviz-dev\
#   libjsoncpp-dev\
#   ca-certificates \
#   iptables \
#   pkg-config  \
#   # python3-dev\
#   # libtins-dev\
#   # libdublintraceroute-dev\
#   && rm -rf /var/lib/apt/lists/*
# RUN cd ${HOME}/toolkit &&\
#   git clone https://github.com/mfontanini/libtins.git &&\
#   cd libtins &&\
#   mkdir build &&\
#   cd build &&\
#   cmake .. &&\
#   make &&\
#   make install
# RUN cd ${HOME}/toolkit &&\
#   git clone https://github.com/open-source-parsers/jsoncpp.git &&\
#   cd jsoncpp &&\
#   mkdir build &&\
#   cd build &&\
#   cmake .. &&\
#   make &&\
#   make install
# RUN cd ${HOME}/toolkit &&\
#   git clone https://github.com/insomniacslk/dublin-traceroute.git &&\
#   cd dublin-traceroute &&\
#   # git submodule init && git submodule update &&\
#   mkdir build &&\
#   cd build &&\
#   cmake .. &&\
#   make &&\
#   make install
# # RUN cd ${HOME}/toolkit &&\
# #   git clone https://github.com/insomniacslk/dublin-traceroute.git &&\
# #   cd dublin-traceroute &&\
# #   # build and install routest
# #   set -exu; \
# #   cd ${HOME}/toolkit/dublin-traceroute &&\
# #   go mod init &&\
# #   cd ./go/dublintraceroute/cmd/routest &&\
# #   go get -v ./... &&\
# #   go build &&\
# #   go install &&\
# #   # build dublin-traceroute (CPP)
# #   cd ${HOME}/toolkit/dublin-traceroute &&\
# #   rm -rf build; mkdir build; cd build &&\
# #   cmake .. &&\
# #   make &&\
# #   make install &&\
# #   # build dublin-traceroute (Go)
# #   cd ${HOME}/toolkit/dublin-traceroute &&\
# #   cd ./go/dublintraceroute/cmd/dublin-traceroute &&\
# #   go get -v ./... &&\
# #   go build
# RUN cd ${HOME}/toolkit &&\
#   git clone https://github.com/insomniacslk/python-dublin-traceroute.git &&\
#   cd python-dublin-traceroute &&\
#   pip3 install graphviz tabulate setuptools_scm &&\
#   python3 setup.py install

# ..............................................................................


#############################
# INIT CLEAN UP
#############################

RUN \
  apt-get -y autoremove && \
  apt-get clean && \
  rm -rf \
  /tmp/* \
  /var/lib/apt/lists/* \
  /var/tmp/*

#############################
# LAST STEPS
#############################

ENV SHELL /usr/bin/zsh
RUN mkdir -p /tmp/logging/
RUN mkdir -p /tmp/docs/

# ..............................................................................

ENTRYPOINT script -f --timing=/tmp/logging/"log_`date +'%F_%T'`.time" /tmp/logging/"log_`date +'%F_%T'`.log" && /bin/zsh
