FROM ubuntu:18.04

RUN echo "nameserver 8.8.4.4" > /etc/resolv.conf && apt-get update

RUN echo "nameserver 8.8.4.4" > /etc/resolv.conf && apt-get install -y apt-utils sudo build-essential git wget curl 

ENV ETCD_VER="3.4.0"

RUN wget https://github.com/etcd-io/etcd/releases/download/v${ETCD_VER}/etcd-v${ETCD_VER}-linux-amd64.tar.gz

RUN tar xvf etcd-v${ETCD_VER}-linux-amd64.tar.gz

RUN sudo mv etcd-v${ETCD_VER}-linux-amd64/etcd etcd-v${ETCD_VER}-linux-amd64/etcdctl /usr/local/bin

COPY ./.circleci/scripts/etcd_entrypoint.sh etcd_entrypoint.sh

RUN sudo chmod +x etcd_entrypoint.sh

EXPOSE 2379
EXPOSE 2380

LABEL com.circleci.preserve-entrypoint=true

ENTRYPOINT ["/etcd_entrypoint.sh"]


