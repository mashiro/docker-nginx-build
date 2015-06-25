FROM debian:jessie
MAINTAINER mashiro <mail@mashiro.org>

ENV GOPATH /go
ENV PATH /nginx/sbin:/go/bin:$PATH

RUN apt-get update && \
    apt-get install -y ca-certificates \
      g++ \
      make \
      git \
      wget \
      golang && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /tmp/nginx
WORKDIR /tmp/nginx

RUN go get -u github.com/cubicdaiya/nginx-build

ONBUILD ADD version configs modules ./
ONBUILD RUN NGINX_VERSION=$(cat version) && \
  mkdir -p /tmp/nginx/work && \
  nginx-build -verbose -v $NGINX_VERSION -d work -prefix /nginx -m modules $(cat configs) && \
  cd work/$NGINX_VERSION/nginx-$NGINX_VERSION && \
  make install && \
  rm -rf /tmp/nginx/work

ONBUILD EXPOSE 80 443
ONBUILD CMD ["nginx", "-g", "daemon off;"]
