[![Docker Hub Info](http://dockeri.co/image/blacklabelops/fluentd)](https://registry.hub.docker.com/u/blacklabelops/fluentd)

[![Docker Build Status](http://hubstatus.container42.com/blacklabelops/fluentd)](https://registry.hub.docker.com/u/blacklabelops/fluentd)
[![Circle CI](https://circleci.com/gh/blacklabelops/fluentd/tree/master.svg?style=shield)](https://circleci.com/gh/blacklabelops/fluentd/tree/master)
[![Image Layers](https://badge.imagelayers.io/blacklabelops/fluentd:latest.svg)](https://imagelayers.io/?images=blacklabelops/fluentd:latest 'Get your own badge on imagelayers.io')


This is a side-car container that can hook to your docker or container logfiles. There is no additional
need for log demons or logging processes inside your docker containers. It crawls for
log files inside docker volumes and attach them to fluentd. The default
behavior of this container is aggregating all logs inside one output logfile.

This container can be used as a base container for any output scenario:

* [Loggly](https://www.loggly.com/): The loggly output container version blacklabelops/loggly can be found in [fluentd-loggly/](./fluentd-loggly/README.md).
* [Files](https://github.com/blacklabelops/fluentd): This one.

# Make It Short

In short, this container can collect all logs from your complete docker environment and producing an aggraget log file. Just by running:

~~~~
$ docker run -d \
	-v /var/lib/docker/containers:/var/lib/docker/containers \
	-v /var/log/docker:/var/log/docker \
	-v $(pwd)/logs:/opt/fluentd/logs \
	-e "LOGS_DIRECTORIES=/var/lib/docker/containers /var/log/docker" \
	blacklabelops/fluentd
~~~~

> Mounts the docker system logs and attaches to all log files in the respective directories. The output will be written inside the
current folder under /logs.

Now list the log files:

~~~~
$ ls logs/
~~~~

# How To Attach Containers and Their Logs

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

## Customize Log Folder

You can define your own log folders. The container will by default crawl for
files ending with **.log**. log folder have to be separated by empty spaces. This is useful when you mount volumes from several containers.

~~~~
$ docker run -d \
  --volumes-from jenkins \
  -e "LOGS_DIRECTORIES=/var/log /jenkins" \
  --name fluentd \
  blacklabelops/fluentd
~~~~

> Will crawl for log files inside /var/log and /jenkins

## Customize Log File Ending

You can define the file endings fluentd will attach to. The container will by default crawl for
files ending with **.log**. This can be overriden and extended to any amount of file endings.

~~~~
$ docker run -d \
  --volumes-from jenkins \
  -e "LOGS_DIRECTORIES=/jenkins" \
  -e "LOG_FILE_ENDINGS=log xml" \
  --name fluentd \
  blacklabelops/fluentd
~~~~

> Crawls for file endings .log and .xml.

You can check and see that fluentd attaches to any xml file he can find under /jenkins:

~~~~
$ docker logs fluentd
...
2015-07-24 19:28:48 +0000 [info]: plugin/in_tail.rb:477:initialize: following tail of /jenkins/plugins/mailer/META-INF/maven/org.jenkins-ci.plugins/mailer/pom.xml
2015-07-24 19:28:48 +0000 [info]: plugin/in_tail.rb:477:initialize: following tail of /jenkins/plugins/maven-plugin/WEB-INF/licenses.xml
...
~~~~

## Customize Log File Format

You can customize the file fomat. The container will by default use the format **none**. This can be overriden by
the parameter LOG_FILE_FORMAT:

~~~~
$ docker run -d \
  --volumes-from jenkins \
	-e "LOG_FILE_FORMAT=none" \
  --name fluentd \
  blacklabelops/fluentd
~~~~

> This parameter will be set for ALL logfiles. For more formats and regexes check the [Fluentd Documentation](http://docs.fluentd.org/articles/in_tail).

## Pos Files

Pose Files will be written to Docker Volume /opt/fluentd

# How To Customize the Log

This container is using the fluentd file Output plugin in order to write the aggregated logfiles.

The full documentation can be found here: [file Output Plugin](http://docs.fluentd.org/articles/out_file)

You can override parameters with the following environment variables, see the plugin documentation for valid values:

* FILE_LOG_PATH corresponds to plugin parameter `path`.
* FILE_LOG_TIME_SLICE_FORMAT corresponds to plugin parameter `time_slice_format`.
* FILE_LOG_TIME_SLICE_WAIT corresponds to plugin parameter `time_slice_wait`.
* FILE_LOG_TIME_FORMAT corresponds to plugin parameter `time_format`.
* FILE_LOG_FLUSH_INTERVAL corresponds to plugin parameter `flush_interval`.
* FILE_LOG_COMPRESS corresponds to plugin parameter `compress`
* FILE_LOG_APPEND corresponds to plugin parameter `append`
* FILE_LOG_FORMAT corresponds to plugin parameter `format`

Full example:

~~~~
$ docker run -d \
	-v /var/lib/docker/containers:/var/lib/docker/containers \
	-v /var/log/docker:/var/log/docker \
	-v $(pwd)/logs:/opt/fluentd/logs \
	-e "LOGS_DIRECTORIES=/var/lib/docker/containers /var/log/docker" \
	-e "FILE_LOG_PATH=/opt/fluentd/logs/container" \
	-e "FILE_LOG_TIME_SLICE_FORMAT=%Y%m%d%H" \
	-e "FILE_LOG_TIME_SLICE_WAIT=10m" \
	-e "FILE_LOG_TIME_FORMAT=%Y-%m-%d-%H-%M-%S" \
	-e "FILE_LOG_FLUSH_INTERVAL=60s" \
	-e "FILE_LOG_COMPRESS=true" \
	-e "FILE_LOG_APPEND=true" \
	-e "FILE_LOG_FORMAT=out_file" \
	blacklabelops/fluentd
~~~~

> Logs all docker logs with the specified plugin parameters.

## Disabling the Basic behavior

You can disable the file log out. This is useful when using this container as a base image for
your custom container. The log file is disabled by the environment variable `DISABLE_FILE_OUT`.

Example:

~~~~
$ docker run -d \
	-v /var/lib/docker/containers:/var/lib/docker/containers \
	-v /var/log/docker:/var/log/docker \
	-v $(pwd)/logs:/opt/fluentd/logs \
	-e "LOGS_DIRECTORIES=/var/lib/docker/containers /var/log/docker" \
	-e "DISABLE_FILE_OUT=true" \
	blacklabelops/fluentd
~~~~

> No attached logs will be written, the fluentd container is practically useless without another out plugin.

# How To Extend This Image

Use this Dockerfile template:

~~~~
FROM blacklabelops/fluentd
MAINTAINER You

#Install plugins and tools
RUN gem install ...

# disable file logging from base container
ENV DISABLE_FILE_OUT=true

WORKDIR /etc/fluent
COPY your-docker-entrypoint.sh /your/locations/your-docker-entrypoint.sh
ENTRYPOINT ["/your/locations/your-docker-entrypoint.sh"]
CMD ["fluentd"]
~~~~

Write your entrypoint like this:

~~~~
#!/bin/bash

# your instructions
...

# Invoke entrypoint of parent container
if [ "$1" = 'fluentd' ]; then
  /etc/fluent/docker-entrypoint.sh $@
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


## References

* [Fluentd Homepage](http://www.fluentd.org/)
* [Docker Homepage](https://www.docker.com/)
* [Docker Userguide](https://docs.docker.com/userguide/)
