
FROM        ubuntu:16.04
ENV         REFRESHED_AT 2018-02-01

# Update system
RUN DEBIAN_FRONTEND=noninteractive apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yqq \
    wget \
    curl \
    vim \
    dnsutils \
    python-pip \
    python-dev \
    python-apt \
    software-properties-common \
    dmidecode

# Install salt master/minion/cloud/api
RUN echo "deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest xenial main" | tee /etc/apt/sources.list.d/saltstack.list && \
    wget -q -O- "https://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest/SALTSTACK-GPG-KEY.pub" | apt-key add - && \
    DEBIAN_FRONTEND=noninteractive apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yqq \
    salt-master \
    salt-minion \
    salt-cloud \
    salt-api \
    salt-ssh \
    salt-syndic

# Install requirments for gitfs_remotes
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install \
    python-dev \
    libffi-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    libssh2-1 \
    libgit2-dev \
    python-pip \
    libgit2-24 \
    python-pygit2
    
# Clean image
RUN apt-get -yqq clean && \
    apt-get -yqq purge && \
    rm -rf /tmp/* /var/tmp/* && \
    rm -rf /var/lib/apt/lists/*

# Add salt config files
COPY etc/master /etc/salt/master
COPY etc/minion /etc/salt/minion
COPY etc/reactor /etc/salt/master.d/reactor
COPY github/key /root/key
COPY github/key.pub /root/key.pub

RUN chmod 600 /root/key

# Expose volumes
VOLUME ["/etc/salt/pki", "/var/log/salt"]

WORKDIR /srv/salt
EXPOSE 4505 4506
COPY start.sh /start.sh
CMD ["bash", "/start.sh"]