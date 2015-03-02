FROM ubuntu:14.04
MAINTAINER Codey Oxley
# Set following in environment:
#   PGHOST
#   PGPORT
#   PGDATABASE
#   PGUSER
#   PGPASS
#   WELCOME_MSG

EXPOSE 1337
RUN apt-get install -y curl \
                       python2.7
RUN echo "deb http://spritelink.github.io/NIPAP/repos/apt stable main extra" \
    > /etc/apt/sources.list.d/nipap.list
RUN curl -L https://spritelink.github.io/NIPAP/nipap.gpg.key | apt-key add -
RUN apt-get update && flock /etc/nipap apt-get install -y nipapd

RUN mkdir /scripts
COPY sql /sql 
COPY nipap-init.py /scripts/
COPY conf/* /etc/nipap/
CMD bash -c 'python2 /scripts/nipap-init.py && nipapd'
