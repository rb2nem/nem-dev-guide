+++
prev = "/01-intro"
next = "/99-references"
weight = 20
title = "About this guide"
date = "2017-04-01T15:02:00+02:00"
toc = true

+++

This guide is a work in progress, and its organisation might evolve significantly. This page should however give an up to date
overview of to use it.

## Help improve the guide

Every page of this guide is editable by everyone in the web browser on Github thanks to the link "Edit this page" in the upper right corner.
Clicking this link will lead you to Github, asking you to [fork the repository](https://help.github.com/articles/fork-a-repo/) to edit the page.
After you save your changes in your own copy
of the repository, you can send a [pull request](https://help.github.com/articles/about-pull-requests/) to have your changes included in the guide.
Help us improve this guide!

## Tools

We will use [httpie](https://httpie.org/) to interact with the NEM Information Server. It provides easy specification of
[query string parameters](https://httpie.org/doc#querystring-parameters), [URL shortcuts for localhost](https://httpie.org/doc#url-shortcuts-for-localhost)
 (which will shorten your typing if your NIS is listening on localhost, as it is the case if you use the guide's docker image described below) and
many other goodies. Check its [documentation](https://httpie.org/doc) for more details.

httpie also outputs colored and readable information about the request and its response. Example in this guide will include httpie's output
when relevant. As an example, here is the output when querying google.com, where oyu can see the first line is the command executed, then comes the request, followed by the response headers and the response body:

{{< code "code/about_google.html" >}} 

## Docker config

A docker config has been implemented to accompany this dev guide. It is located in the [`docker/` subdirectory of this very repository](https://github.com/rb2nem/nem-dev-guide).
It is a docker image based on Ubuntu 16.04, the latest long term support release available.
When you run the container, it start a NIS node on the testnet.

NIS is started by [supervisord](http://www.supervisord.org). The NIS data is stored under /var/lib/nem, and the logs are available at 
`/var/log/nis-stderr.log` and `/var/log/nis-stdout.log`.

### Using the docker config
To build the Docker image, go in the subdirectory and issue the build command:
```
cd docker/
docker build -t testdev .
```
You can now run a container based on the image. The best and advised solution is to create a directory on your host in which the 
data of NIS will be persistently stored. That way you can create a new container without having to redownload the whole NEM blockchain
(eg in case of upgrades of NIS). In our example we will store the data in `/data/nis-data`, but you can choose another location as long
as you pass it as an absolute path (ie the path must start with `/`).
```
persistent_location="/data/nis-data"
[[ -d $persistent_location ]] || mkdir $persistent_location
docker run -it --rm -v $persistent_location:/var/lib/nem -p 7890:7890 testdev bash
```

This will drop you in a shell from which you can replicate the commands in this dev guide. The NIS is listening on localhost port 7890.
If you want to make NIS available from your host, you just have to pass this additional flags: `-p 7890:7890`.

### Customising the docker config
You can of course customise the docker image built. Just remember that the Dockerfile of this guide might also evolve. If you want to 
follow the changes of it, you might have to merge your changes. Strategies to do that might be to use `git stash` or a dedicated git branch
which you rebase. Explaining this is out of scope of this guide though.
