Docker image for nipapd
=======================


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
| NIPAP_USER  | N/A                    |
+-------------+------------------------+
| NIPAP_PASS  | N/A                    |
+-------------+------------------------+

``/etc/nipap/nipap.conf`` is generated from the variables above.

The ``NIPAP_USER`` and ``NIPAP_PASS`` variables determine what credentials to
be created at startup. If they are not provided, not will be created.

The preferred way to reach postgres from the container is via a
linked-container to nipap-psql, but of course as long as you supply the correct
data into the variables that'll be fine.

With no extra work, this image will start up nipapd making sure the postgres
database has the proper schema and connect to it then create a user. Since by
their nature docker containers don't have data persistence, if you wish to have
more than one nipap user this probably won't do.

Luckily setting up host bound container volumes is an easy way to circumvent 
that and allow easy config adjustments without needing to customize the image
to care about additional environment variables. It will also allow your
nipap-www container to share the same database as nipapd like they would being
on the same machine.

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
               -e NIPAP_USER=coxley \
               -e NIPAP_PASS=something_strong \
               coxley/nipapd

    # Now start up the container for the web interface
    docker run --name nipap-www -td \
               --volumes-from nipap-conf \
               --link nipapd:nipapd \
               -p 5000:5000 \
               -e NIPAPD_USER=coxley \
               -e NIPAPD_PASS=something_strong \
               -e DEBUG=false \
               -e WELCOME_MSG="New Docker Container!" \
               coxley/nipap-www


Feel free to create the container volume with nothing in it. This image will
still auto-generate the config and copy the base schema sqlite database in if 
none are in there. If the files do exist, though, it will skip that part.

If you want data persistence for the database (I imagine you do), you will need
to create a volume on the postgres container for /opt/postgresql/data. For
example, adding the argument 
``-v /opt/docker/volumes/nipap/db:/opt/postgresql/data`` or wherever you wish
to store the data on the host.
