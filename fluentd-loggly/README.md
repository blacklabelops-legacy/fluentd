# BlackLabelOps/Loggly

[![Docker Hub Info](http://dockeri.co/image/blacklabelops/loggly)](https://registry.hub.docker.com/u/blacklabelops/loggly)

[![Docker Build Status](http://hubstatus.container42.com/blacklabelops/loggly)](https://registry.hub.docker.com/u/blacklabelops/loggly)
[![Circle CI](https://circleci.com/gh/blacklabelops/fluentd/tree/master.svg?style=shield)](https://circleci.com/gh/blacklabelops/fluentd/tree/master)
[![Image Layers](https://badge.imagelayers.io/blacklabelops/loggly:latest.svg)](https://imagelayers.io/?images=blacklabelops/loggly:latest 'Get your own badge on imagelayers.io')

This is a side-car container that can hook to your docker or container logfiles. There is no additional
need for log demons or logging processes inside your docker containers. It crawls for
log files inside docker volumes and logs to loggly.

Great for Cloud Containers! I use this inside the Google Container Cloud.

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
	-e "LOGGLY_TOKEN=3ere-23kkke-23j3oj-mmkme-343" \
  --name loggly \
  blacklabelops/loggly
~~~~

> Now grab logs by typing docker logs loggly

You should find something like this inside your log:

~~~~
$ docker logs loggly
...
2015-07-24 18:53:44 +0000 [info]: plugin/in_tail.rb:477:initialize: following tail of /var/log/jenkins.log
...
~~~~

# Customize Loggly Tag

You can define your own loggly log tag.

~~~~
$ docker run -d \
  --volumes-from jenkins \
	-e "LOGGLY_TOKEN=3ere-23kkke-23j3oj-mmkme-343" \
	-e "LOGGLY_TAG=jenkinslog" \
  --name loggly \
  blacklabelops/loggly
~~~~

# Customize Log Directories, File Endings and More

Read the README of the base container.

[blacklabelops/fluentd](../README.md)

## References

* [Loggly Homepage](https://www.loggly.com/)
* [Fluentd Homepage](http://www.fluentd.org/)
* [Docker Homepage](https://www.docker.com/)
* [Docker Userguide](https://docs.docker.com/userguide/)
