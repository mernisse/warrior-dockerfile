FROM debian:sid-slim
LABEL version="1.0.0" \
	description="ArchiveTeam Warrior container"

# Install dependencies
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
	curl \
	git \
	net-tools \
	libgnutls30 \
	liblua5.1-0 \
	python \
	python-pip \
	python-setuptools \
	python3 \
	python3-pip \
	python3-setuptools \
	sudo \
	wget \
	&& useradd -d /home/warrior -m -U warrior \
	&& echo "warrior ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
	&& mkdir -p /data/data \
	&& chown -R warrior:warrior /data/data

RUN apt-get install -y --no-install-recommends \
	autoconf \
	build-essential \
	flex \
	libgnutls28-dev \
	libidn2-0-dev \
	uuid-dev \
	libpsl-dev \
	libpcre2-dev \
	liblua5.1-0-dev

WORKDIR /tmp
RUN curl -o wget-1.14.lua.LATEST.tar.bz2 \
		https://warriorhq.archiveteam.org/downloads/wget-lua/wget-1.14.lua.LATEST.tar.bz2 \
	&& tar -jxf /tmp/wget-1.14.lua.LATEST.tar.bz2 \
		--strip-components=1

RUN ./configure --with-ssl=gnutls --disable-nls \
	&& make \
	&& cp src/wget /usr/bin/wget-lua \
	&& chmod a+x /usr/bin/wget-lua

RUN apt-get remove -y --purge \
	autoconf \
	curl \
	build-essential \
	flex \
	libgnutls28-dev \
	libidn2-0-dev \
	uuid-dev \
	libpsl-dev \
	libpcre2-dev \
	liblua5.1-0-dev \
	&& apt-get clean -y \
	&& apt-get autoremove -y --purge \
	&& rm -r /var/lib/apt/lists/* \
	&& rm -r /tmp/*

RUN pip install requests \
	&& pip install six \
	&& pip install warc \
	&& pip3 install requests \
	&& pip3 install six \
	&& pip3 install warc

RUN pip3 install seesaw

WORKDIR /home/warrior
USER warrior
RUN mkdir /home/warrior/projects

# Expose the persistent data to the host.  This will allow the user
# to not have to reconfigure the container across runs.
VOLUME /data/data
VOLUME /home/warrior/projects/config.json

# Expose web interface port
EXPOSE 8001

ENTRYPOINT ["run-warrior3", \
	"--projects-dir", "/home/warrior/projects", \
	"--data-dir", "/data/data", \
	"--warrior-hq", "http://warriorhq.archiveteam.org", \
	"--port", "8001", \
	"--real-shutdown"]
