#!/usr/bin/env bash

if [ ! -e ../googleapis ] 
then 
  git clone https://github.com/googleapis/googleapis.git ../googleapis;
fi

find ./protos -type f -name "*.proto" | xargs -I '{}' protoc -I ./protos/etcd/etcdserver/etcdserverpb/ -I ../googleapis/ -I ./protos --elixir_out=plugins=grpc:./lib/priv/ {}
