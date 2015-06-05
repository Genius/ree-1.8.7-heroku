FROM ubuntu:14.04

MAINTAINER Sam Kottler <shk@linux.com>

ADD . /app

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential python curl zlib1g-dev libssl-dev libreadline-gplv2-dev

EXPOSE 8000

CMD ["/app/build_ree.sh"]
