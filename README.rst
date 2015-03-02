Description
-----------

Docker container for running nipapd. Requires that you already have a
correctly setup postgresql server. For fast readiness, there is an existing
docker container `here`_.

.. _here: https://github.com/docker-nipap/nipap-psql

Setup
-----

Most of the setup is controlled by passing in environment variables to
``docker run``. This allows for easier setup for different environments.

Below are the current used variables and their defaults:

+-------------+------------------------+
| PGHOST      | postgres               |
+-------------+------------------------+
| PGPORT      | 5432                   |
+-------------+------------------------+
| PGDATABASE  | nipap                  |
+-------------+------------------------+
| PGUSER      | nipap                  |
+-------------+------------------------+
| PGPASS      | nipap                  |
+-------------+------------------------+
| WELCOME_MSG | NIPAP Docker Container |
+-------------+------------------------+

``/etc/nipap/nipap.conf`` is generated from the variables above.

The preferred way to reach postgres from the container is via a
linked-container to nipap-psql, but of course as long as you supply the correct
data into the variables that'll be fine.

With no extra work, this image will start up nipapd making sure the postgres
database has the proper schema and connect to it then create a user. Since by
their nature docker containers don't have data persistence, if you wish to have
more than one nipap user this probably won't do.

Luckily setting up host bound container volumes is an easy way to circumvent 
that and allow easy config adjustments without needing to customize the image
to care about additional environment variables.

On your docker host simply create a directory that you want to resemble
``/etc/nipap``, create a container volume and mount to your nipapd instance.

The below is a working full example::

    # Launch psql container
    docker run --name postgres -td \
               -e POSTGRES_PASSWORD=nipap \
               -e POSTGRES_USER=nipap \
               coxley/nipap-psql

    # Create container volume. Doesn't actually start a new container.
    # Just provides volume sharing
    NIPAP_CONF=/opt/docker/volumes/nipap/conf
    mkdir -p $NIPAP_CONF
    docker create --name nipap-conf -v $NIPAP_CONF ubuntu:14.04

    # Start up nipapd container, link volume, and link to postgres
    docker run --name nipapd -td \
               --volumes-from nipap-conf \
               --link postgres:postgres \
               coxley/nipapd

Feel free to create the container volume with nothing in it. This image will
still auto-generate the config and copy base sqlite database in if none are in
there. If the files do exist, though, it will skip that part.