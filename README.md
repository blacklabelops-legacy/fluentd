# Dockerized Fluentd

[![Docker Stars](https://img.shields.io/docker/stars/blacklabelops/fluentd.svg)](https://hub.docker.com/r/blacklabelops/fluentd/) [![Docker Pulls](https://img.shields.io/docker/pulls/blacklabelops/fluentd.svg)](https://hub.docker.com/r/blacklabelops/fluentd/)

## Supported tags and respective Dockerfile links

Leave a message and ask questions on Hipchat: [blacklabelops/hipchat](https://www.hipchat.com/geogBFvEM)

| Bundle | Version | Tags  | Dockerfile | Readme | Example |
|--------|---------|-------|------------|--------|---------|
| Fluentd | latest | latest | [Dockerfile](https://github.com/blacklabelops/fluentd/blob/master/Dockerfile) | [Readme](https://github.com/blacklabelops/fluentd/blob/master/README.md) | blacklabelops/fluentd:latest |
| Loggly | latest | loggly | [Dockerfile](https://github.com/blacklabelops/fluentd/blob/master/fluentd-loggly/Dockerfile) | [Readme](https://github.com/blacklabelops/fluentd/blob/master/fluentd-loggly/README.md) | blacklabelops/fluentd:loggly |

# Make It Short

In short, this container can collect all logs from your complete docker environment and producing an aggraget log file. Just by running:

~~~~
$ docker run -d \
	-v /var/lib/docker/containers:/var/lib/docker/containers \
	-v /var/log/docker:/var/log/docker \
	-v $(pwd)/logs:/opt/fluentd/logs \
	-e "TAIL_LOGS_DIRECTORIES=/var/lib/docker/containers /var/log/docker" \
	blacklabelops/fluentd
~~~~

> Mounts the docker system logs and attaches to all log files in the respective directories. The output will be written inside the
current folder under /logs.

Now list the log files:

~~~~
$ ls logs/
~~~~

# How To Attach Containers and Logs

In order to attach the side-car container to your logs you have to put your container's log inside
Docker volumes. Simply add **-v /var/log** to your container's run command.

Here's an example with my [blacklabelops/jenkins](https://github.com/blacklabelops/jenkins) container:

~~~~
$ docker run -d -p 8090:8080 \
  -v /var/log \
  --name jenkins \
  blacklabelops/jenkins
~~~~

> Container logs to /var/log/jenkins.log.

Now attach the container simply by mounting it's volume. The container attaches by default to any file ending with **.log** inside the folder **/var/log**

~~~~
$ docker run -d \
  --volumes-from jenkins \
  --name fluentd \
  blacklabelops/fluentd
~~~~

> Now grab logs by typing docker logs fluentd

You should find something like this inside your log:

~~~~
$ docker logs fluentd
...
2015-07-24 18:53:44 +0000 [info]: plugin/in_tail.rb:477:initialize: following tail of /var/log/jenkins.log
...
~~~~

# Log File Pattern

Log file pattern with the ability to define file patterns.

~~~~
$ docker run -d \
  --volumes-from jenkins \
  -e "TAIL_LOGS_DIRECTORIES=/var/log" \
	-e "TAIL_LOG_FILE_PATTERN=*" \
  --name fluentd \
  blacklabelops/fluentd
~~~~

> Attaches to all files inside those folders

# Log File Regex

# Customize Log Folder

You can define your own log folders. The container will by default crawl for
files ending with **.log**. log folder have to be separated by empty spaces. This is useful when you mount volumes from several containers.

~~~~
$ docker run -d \
  --volumes-from jenkins \
  -e "TAIL_LOGS_DIRECTORIES=/var/log /jenkins" \
  --name fluentd \
  blacklabelops/fluentd
~~~~

> Will crawl for log files inside /var/log and /jenkins

# Customize Log File Ending

*THIS IS DEPRECATED! USE LOG FILE PATTERN INSTEAD!*

# Customize Log File Format

You can customize the file fomat. The container will by default use the format **none**. This can be overriden by
the parameter LOG_FILE_FORMAT:

~~~~
$ docker run -d \
  --volumes-from jenkins \
	-e "TAIL_LOG_FILE_FORMAT=none" \
  --name fluentd \
  blacklabelops/fluentd
~~~~

> This parameter will be set for ALL logfiles. For more formats and regexes check the [Fluentd Documentation](http://docs.fluentd.org/articles/in_tail).

# Pos Files

Pose Files will be written to Docker Volume /opt/fluentd

# How To Customize the Log

This container is using the fluentd file Output plugin in order to write the aggregated logfiles.

The full documentation can be found here: [file Output Plugin](http://docs.fluentd.org/articles/out_file)

You can override parameters with the following environment variables, see the plugin documentation for valid values:

* TAIL_FILE_LOG_PATH corresponds to plugin parameter `path`.
* TAIL_FILE_LOG_TIME_SLICE_FORMAT corresponds to plugin parameter `time_slice_format`.
* TAIL_FILE_LOG_TIME_SLICE_WAIT corresponds to plugin parameter `time_slice_wait`.
* TAIL_FILE_LOG_TIME_FORMAT corresponds to plugin parameter `time_format`.
* TAIL_FILE_LOG_FLUSH_INTERVAL corresponds to plugin parameter `flush_interval`.
* TAIL_FILE_LOG_COMPRESS corresponds to plugin parameter `compress`
* TAIL_FILE_LOG_APPEND corresponds to plugin parameter `append`
* TAIL_FILE_LOG_FORMAT corresponds to plugin parameter `format`

Full example:

~~~~
$ docker run -d \
	-v /var/lib/docker/containers:/var/lib/docker/containers \
	-v /var/log/docker:/var/log/docker \
	-v $(pwd)/logs:/opt/fluentd/logs \
	-e "TAIL_LOGS_DIRECTORIES=/var/lib/docker/containers /var/log/docker" \
	-e "TAIL_FILE_LOG_PATH=/opt/fluentd/logs/container" \
	-e "TAIL_FILE_LOG_TIME_SLICE_FORMAT=%Y%m%d%H" \
	-e "TAIL_FILE_LOG_TIME_SLICE_WAIT=10m" \
	-e "TAIL_FILE_LOG_TIME_FORMAT=%Y-%m-%d-%H-%M-%S" \
	-e "TAIL_FILE_LOG_FLUSH_INTERVAL=60s" \
	-e "TAIL_FILE_LOG_COMPRESS=true" \
	-e "TAIL_FILE_LOG_APPEND=true" \
	-e "TAIL_FILE_LOG_FORMAT=out_file" \
	blacklabelops/fluentd
~~~~

> Logs all docker logs with the specified plugin parameters.

# How To Extend This Image

Use this Dockerfile template:

~~~~
FROM blacklabelops/fluentd
MAINTAINER You

#Install plugins and tools
RUN gem install ...

# disable file logging from base container
ENV DISABLE_FILE_OUT=true

WORKDIR /opt/fluentd
COPY your-docker-entrypoint.sh /your/locations/your-docker-entrypoint.sh
ENTRYPOINT ["/bin/tini","--","/your/locations/your-docker-entrypoint.sh"]
CMD ["fluentd"]
~~~~

Write your entrypoint like this:

~~~~
#!/bin/bash

# your instructions
...

# Invoke entrypoint of parent container
if [ "$1" = 'fluentd' ]; then
  exec /opt/fluentd/docker-entrypoint.sh $@
fi

exec "$@"
~~~~

# Vagrant

Vagrant is fabulous tool for pulling and spinning up virtual machines like docker with containers. I can configure my development and test environment and simply pull it online. And so can you! Install Vagrant and Virtualbox and spin it up. Change into the project folder and build the project on the spot!

~~~~
$ vagrant up
$ vagrant ssh
[vagrant@localhost ~]$ cd /vagrant
[vagrant@localhost ~]$ ./scripts/build.sh
~~~~

> Will build the container from source.

Vagrant does not leave any docker artifacts on your beloved desktop and the vagrant image can simply be destroyed and repulled if anything goes wrong. Test my project to your heart's content!

First install:

* [Vagrant](https://www.vagrantup.com/)
* [Virtualbox](https://www.virtualbox.org/)


# References

* [Fluentd Homepage](http://www.fluentd.org/)
* [Docker Homepage](https://www.docker.com/)
* [Docker Userguide](https://docs.docker.com/userguide/)
