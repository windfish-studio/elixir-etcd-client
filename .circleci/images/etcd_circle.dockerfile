FROM ubuntu:18.04

RUN echo "nameserver 8.8.4.4" > /etc/resolv.conf && apt-get update

RUN echo "nameserver 8.8.4.4" > /etc/resolv.conf && apt-get install -y apt-utils sudo build-essential git wget curl 

RUN adduser --disabled-password app

#Make app user sudoer with no password required
RUN echo "app ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers
RUN mkdir -p /home/app
RUN chown -R app:app /home/app
RUN chmod -R 755 /home/app

USER app
ENV HOME="/home/app"
WORKDIR $HOME

RUN sudo chown -R app:app $HOME
RUN sudo chmod 755 $HOME

ENV ETCD_VER="3.4.0"

RUN wget https://github.com/etcd-io/etcd/releases/download/v${ETCD_VER}/etcd-v${ETCD_VER}-linux-amd64.tar.gz 

RUN tar xvf etcd-v${ETCD_VER}-linux-amd64.tar.gz 

RUN sudo mv etcd-v${ETCD_VER}-linux-amd64/etcd etcd-v${ETCD_VER}-linux-amd64/etcdctl /usr/local/bin 

COPY ./.circleci/scripts/etcd_entrypoint.sh etcd_entrypoint.sh

RUN sudo chmod +x /home/app/etcd_entrypoint.sh

EXPOSE 2379
EXPOSE 2380

LABEL com.circleci.preserve-entrypoint=true

ENTRYPOINT ["/home/app/etcd_entrypoint.sh"]


