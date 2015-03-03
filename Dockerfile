FROM ubuntu:14.04
MAINTAINER Codey Oxley
EXPOSE 1337
# Set following in environment:
#   PGHOST
#   PGPORT
#   PGDATABASE
#   PGUSER
#   PGPASS
#   NIPAP_USER
#   NIPAP_PASS

# Gather nipap dist
RUN apt-get install -y curl \
                       python2.7
RUN echo "deb http://spritelink.github.io/NIPAP/repos/apt stable main extra" \
    > /etc/apt/sources.list.d/nipap.list
RUN curl -L https://spritelink.github.io/NIPAP/nipap.gpg.key | apt-key add -
RUN apt-get update && apt-get \
                      -o Dpkg::Options::="--force-confdef" \
                      -o Dpkg::Options::="--force-confold" \
                      install -y nipapd

# Custom
RUN mkdir /scripts
COPY sql /sql 
COPY nipap-init.py /scripts/
COPY conf/* /etc/nipap/
CMD bash -c 'python2 /scripts/nipap-init.py && nipapd'
