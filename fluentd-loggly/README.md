Leave a message and ask questions on Hipchat: [blacklabelops/hipchat](https://www.hipchat.com/geogBFvEM)

This is a side-car container that can hook to your docker or container logfiles. There is no additional
need for log demons or logging processes inside your docker containers. It crawls for
log files inside docker volumes and logs to loggly.

Great for Cloud Containers! I use this inside the Google Container Cloud.

# Make It Short

You can send all your docker logs to Loggly just by typing:

~~~~
$ docker run -d \
		-p 24224:24224 \
		-e "FLUENTD_SOURCE_TCP=true" \
		-e "LOGGLY_TOKEN=3ere-23kkke-23j3oj-mmkme-343" \
		--name loggly \
		blacklabelops/fluentd:loggly
~~~~

> Starts a local Fluentd log server with Loggly.com log forwarding.

Now send log messages to Loggly.com!

~~~~
$ docker run --rm --log-driver=fluentd blacklabelops/alpine echo "Hello World"
~~~~

> The docker log-driver mechanism will send all docker log output to Loggly!

# Running Behind a Firewall

If you expose the port with `-p 24224:24224` it will be accesible on the internet. You can restrict this with `-p 127.0.0.1:24224:24224`

~~~~
$ docker run -d \
		-p 127.0.0.1:24224:24224 \
		-e "FLUENTD_SOURCE_TCP=true" \
		-e "LOGGLY_TOKEN=3ere-23kkke-23j3oj-mmkme-343" \
		--name loggly \
		blacklabelops/fluentd:loggly
~~~~

> Will only be accessible by local docker installation

# Attaching To Logs

In short, this container can collect all logs from your complete docker environment and forward them live to loggly. Just by running:

~~~~
$ docker run -d \
	-v /var/lib/docker/containers:/var/lib/docker/containers \
	-v /var/log/docker:/var/log/docker \
	-e "LOGS_DIRECTORIES=/var/lib/docker/containers /var/log/docker" \
	-e "LOGGLY_TOKEN=3ere-23kkke-23j3oj-mmkme-343" \
	--name loggly \
	blacklabelops/fluentd:loggly
~~~~

> Mounts the docker system logs and attaches to all log files in the respective directories. You need a loggly access token from loggly.com.

## Configuration

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
  blacklabelops/fluentd:loggly
~~~~

> Now grab logs by typing docker logs loggly

You should find something like this inside your log:

~~~~
$ docker logs loggly
...
2015-07-24 18:53:44 +0000 [info]: plugin/in_tail.rb:477:initialize: following tail of /var/log/jenkins.log
...
~~~~

## Customize Loggly Tag

You can define your own loggly log tag.

~~~~
$ docker run -d \
  --volumes-from jenkins \
	-e "LOGGLY_TOKEN=3ere-23kkke-23j3oj-mmkme-343" \
	-e "LOGGLY_TAG=jenkinslog" \
  --name loggly \
  blacklabelops/fluentd:loggly
~~~~

## Customize Log Directories, File Endings and More

Read the README of the base container.

[blacklabelops/fluentd](../README.md)

# References

* [Loggly Homepage](https://www.loggly.com/)
* [Fluentd Homepage](http://www.fluentd.org/)
* [Fluentd-Loggly-Plugin](https://github.com/patant/fluent-plugin-loggly)
* [Docker Homepage](https://www.docker.com/)
* [Docker Userguide](https://docs.docker.com/userguide/)
