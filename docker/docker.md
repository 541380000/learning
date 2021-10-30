# Get Ready
## Why docker?
- Out of the box. No more configurations.
- Process isolation. One docker doesn't influence another.
- Fast deployment.

## Install docker on ubuntu 
- Instructions can be found at https://docs.docker.com/engine/install/ubuntu/
- After installation, run `docker run hello-world` to verify.

## Change docker mirror to Alibaba in china
```
sudo vim /etc/docker/daemon.json
```
input the following code
```
{
  "registry-mirrors": [
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com"
  ]
}
```

# Basic of Docker
## Search and filter official mirrors
```
docker search centos  # search centos mirrors
docker search --filter stars=10 mysql # search mysql mirrors with more than 10 stars
docker search --filter "is-official=true" openjdk # search official mirrors of jdk
```

## Pull mirrors
```
docker pull centos:7 # Pull mirrors centos with TAG 7
docker images # or docker image ls to show local image list
```

## Remove hello-world mirror from local
```
docker ps -a  # check all running and stopped containers
docker rm ac7c556a0005  # remove hello-world container
docker image rm feb5d9fea6a5  # remove hello-world mirror
```

## Start, stop and remove containers
```
docker pull centos:7  # pull centos7 image
docker run -it centos:7 # start centos image whose TAG is 7
docker run -it centos # this is equal to ->
docker run -it centos:latest
docker run -itd centos:7 # see below
```
for docker run:
`i`: interactive mode
`t`: start a new terminal for container
`d`: detach process. when you exit from the terminal, container won't stop

- you can use `--name=your_name` to specify a name for container, later you can use name instead of Container ID for convinience
- now start a container with `docker run -itd --name=mycentos centos:7`
- to enter the terminal of container, run `docker exec -it mycentos /bin/bash`
- do something in centos7, then use `exit` to stop
---
- To stop a container, run `docker stop mycentos`
- To resume a stopped container, run `docker start mycentos`
- To remove a running container, run `docker rm -f mycentos` where `-f` means force
- To remove a stopped container, run `docker rm mycentos` 
---
- To see info of container, run `docker inspece mycentos`
---
- To remove all containers, run `docker rm -f $(docker ps -a -q)`, THIS CAN BE DANGEROUS.


## Copy files between host and container
- In host, run `docker cp /home/william/test.txt mycentos:/home/` to copy file to container
- In host, run `docker cp mycentos:/home/test.txt /home/william/` to copy file from container

## Mount folder to container
- In host, run `docker run -v /home/william/foler_to_mount:/home/` to mount host's folder to docker
- If you want to mount an exist container:
```
docker stop mycentos # stop container
docker commit mycentos new_image_name  # create a new image from exist container
docker run -itd -v /home/william/folder_to_mount:/home/ --name=new_container new_image_name  # start a new container from created image
```

# Custom your image
## Custom image with `commit`
When using `commit`, you install and configure everything in a running container, and create an image from the container using `commit`
After than you can create new containers with the image you get.
```
docker run -itd --name=mycentos centos:7  # start a container from official image
docker exec -it mycentos /bin/bash  # start container terminal
# do configuration and installation
yum install net-tools
exit
# Now you are back to host
docker commit -a "William" -m "centos with net tools" mycentos new_image:1
docker image ls
```
in docker commit:
`-a`: author
`-m`: description of image
`new_image:1`: new image name and tag
now you can create container from new_image

##  Custom image with dockerfile: An example
This is a basic dockerfile
```
# this is a dockerfile
FROM centos:7                           # Basic image
MAINTAINER William 1327804001@qq.com    # Maintainer info
RUN echo "Building image!"      
WORKDIR /home/william/
COPY ./README.md /home/william/     # COPY file from host to image. file in host must in the working dir when running docker build
RUN yum install -y net-tools        # run command in centos
```
Put `dockerfile` in a dir and also README.md here, then run `docker build -t new_image:2`


## Example: create jdk11 and tomcat image
We have files:
- `jdk-11.0.12_linux-x64_bin.tar.gz` -> after unzip, it is `jdk-11.0.12`
- `apache-tomcat-8.5.72.tar.gz` -> after unzip, it is `apache-tomcat-8.5.72`

This is dockerfile:
```
FROM centos:7       # base image is centos7
ADD jdk-11.0.12_linux-x64_bin.tar.gz /usr/local     # ADD means unzip tar.gz file to a path, if not .tar.gz file, it is like CP
RUN mv /usr/local/jdk-11.0.12 /usr/local/jdk11
ENV JAVA_HOME=/usr/local/jdk11
ENV CLASSPATH=$JAVA_HOME/lib:$PATH
ENV PATH=$JAVA_HOME/bin:$PATH
RUN echo "Finish installing jdk11!"

ADD apache-tomcat-8.5.72.tar.gz /usr/local/
RUN mv /usr/local/apache-tomcat-8.5.72 /usr/local/tomcat8
EXPOSE 8080
ENTRYPOINT ["/usr/local/tomcat8/catalina.sh", "run"]
```
where
`ENV`: add the string to /etc/profile/
`EXPOSE`: expose contain's port to host
`RUN`: run the command when building image
`ENTRYPOINT`: run the exec format command when running container

then `docker build -t mycentos:jdk ./` and `docker run -itd -p 80:8080 mycentos:jdk /bin/bash` to vefify.


## Example: create nginx image
- installing nginx can be complex. To install on host, we can run this:
```
tar -xzvf nginx-1.21.3.tar.gz -C /home/
yum -y install gcc-c++ gcc pcre pcre-devel zlib zlib-devel make cmake
cd /home/nginx-1.21.3
./configure --prefix=/usr/local/nginx
make -j64 && make install
```
- We will put this code segment into a script and call it in dockerfile.
- dockerfile is like this
```
FROM centos:7
ADD nginx-1.21.3.tar.gz /home/
COPY install.sh /home/
RUN bash /home/install.sh
EXPOSE 80
ENTRYPOINT ["/usr/local/nginx/sbin/nginx","-g", "daemon off;"]
```


## Example: create redis image
dockerfile:
```
FROM centos:7
ADD redis-6.2.6.tar.gz /home/
RUN yum -y install epel-release build-essential g++ gcc gcc-g++ make cmake
RUN cd /home/redis-6.2.6 && make -j20 && make install
RUN mkdir -p /usr/local/redis/conf/
RUN cp /home/redis-6.2.6/redis.conf /usr/local/redis/conf/
RUN sed -i '94s/protected-mode yes/protected-mode no/g' /usr/local/redis/conf/redis.conf
RUN sed -i '75s/127.0.0.1/0.0.0.0/g' /usr/local/redis/conf/redis.conf
EXPOSE 6379
ENTRYPOINT ["redis-server", "/usr/local/redis/conf/redis.conf"]
```
- in the code, redis's default mode is protected mode, which don't allow you to connect from another machine. we disabled it.
- in the code, redis's default listening addr is 127.0.0.1, we change it to 0.0.0.0 to allow every IP to connect.
- using `sed` directly and allowing 0.0.0.0 connect CAN BE DANGEROUS.


## Example: using official MySQL docker image
- pull `docker pull mysql:5.7`
- official doc at: https://registry.hub.docker.com/_/mysql
- run `docker run --name some-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:tag` to run docker



# Network of docker
## How to check network settings of docker
`docker network ls`
there are 3 network mode - bridge, host, none
## Bridge
- When docker service starts, a virtual network adapter is created, called bridge0
- When a container starts, it is connected to bridge0
- bridge0 is connected to network adapter of computer by NAT(Network Address Translation, see https://en.wikipedia.org/wiki/Network_address_translation)

## Host
- Docker service and containers won't have their own IP and port, they use the host's.
- Host mode has better performance in network. But containers may conflict when using ports.

## None
- Containers has no IP and port. It is disconnected from network. Usually used when testing.

## Single direction communication with Link
- normally, container A will be able to access network of container B
- Situation: several Tomcat8 server will connect to one mysql db @ 173.0.0.5. But mysql db is down for some reason. After restart, mysql IP is 173.0.0.10.
Then we have to modify config code of Tomcat8 to change to 173.0.0.10
- Solution: Docker provide a better solution - link.  
- First, start mysql with name mydb `docker run -itd mysql --name=mydb /bin/bash`
- Then, start other contains with `docker run -itd tomcat8 --link mydb`
- This will link addr `mydb` in tomcat8 to container named `mydb`. You can use `ping mydb` in tomcat8 containers to reach MySQL.
- But in mydb, you cannot access tomcat8. Because link is single direction.

## Double direction communication with bridge 
- Create a bridge with `docker network create -d bridge my_bridge`
- Connect tomcat to bridge `docker network connect my_bridge tomcat`
- Connect mydb to bridge `docker network connect my_bridge mydb`
- Then in tomcat you can use `ping mydb`, and in mydb, you can use `ping tomcat`


# Docker compose
## Installation
- Follow instructios here `https://docs.docker.com/compose/install/`

## Study later ... Remaining content is less useful







































