[![Docker Hub Info](http://dockeri.co/image/blacklabelops/fluentd)](https://registry.hub.docker.com/u/blacklabelops/fluentd)

[![Docker Build Status](http://hubstatus.container42.com/blacklabelops/fluentd)](https://registry.hub.docker.com/u/blacklabelops/fluentd)
[![Circle CI](https://circleci.com/gh/blacklabelops/fluentd/tree/master.svg?style=shield)](https://circleci.com/gh/blacklabelops/fluentd/tree/master)
[![Image Layers](https://badge.imagelayers.io/blacklabelops/fluentd:latest.svg)](https://imagelayers.io/?images=blacklabelops/fluentd:latest 'Get your own badge on imagelayers.io')


This is a side-car container that can hook to your docker or container logfiles. There is no additional
need for log demons or logging processes inside your docker containers. It crawls for
log files inside docker volumes and attach them to fluentd. This container can be
used for logging from cloud containers into services like loggly.

The loggly output container version blacklabelops/loggly can be found [in fluentd-loggly/](./fluentd-loggly/README.md).

# Make It Short

In short, this container can collect all logs from your complete docker environment. Just by running:

~~~~
$ docker run -d \
	-v /var/lib/docker/containers:/var/lib/docker/containers \
	-v /var/log/docker:/var/log/docker \
	-e "LOGS_DIRECTORIES=/var/lib/docker/containers /var/log/docker" \
	blacklabelops/fluentd
~~~~

> Mounts the docker system logs and attaches to all log files in the respective directories.

# Configuration

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

# Customize Log Folder

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

# Customize Log File Ending

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

## References

* [Fluentd Homepage](http://www.fluentd.org/)
* [Docker Homepage](https://www.docker.com/)
* [Docker Userguide](https://docs.docker.com/userguide/)
