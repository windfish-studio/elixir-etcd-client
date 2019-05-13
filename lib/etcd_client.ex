defmodule EtcdClient do

  def start_link(opts) do
    channel = get_connection(opts.host, opts.port)
    Registry.register(:etcd_registry, opts.name, channel)
  end

  def get_connection(host, port) do
    {:ok, channel} = GRPC.Stub.connect(host <> ":" <> port,adapter_opts: %{http2_opts: %{keepalive: :infinity}})
    channel
  end

  def close_connection(conn) do
    channel = elem(Enum.fetch!(Registry.lookup(:region_registry, conn), 0),1)
    GRPC.Stub.disconnect(channel)
    Registry.unregister(:etcd_registry, conn)
  end

  defp lookup_channel(conn) do
    channel = elem(Enum.fetch!(Registry.lookup(:etcd_registry, conn), 0),1)
  end

  def put_kv_pair(conn, key, value, lease_id) do
    channel = lookup_channel(conn)
    request = Etcdserverpb.PutRequest.new(key: key, value: value, lease: lease_id, prev_kv: true)
    {:ok, response} = Etcdserverpb.KV.Stub.put(channel,request)
    response
  end

  def get_kv_pair(conn, key) do
    channel = lookup_channel(conn)
    request = Etcdserverpb.RangeRequest.new(key: key)
    {:ok, response} = Etcdserverpb.KV.Stub.range(channel, request)
    response
  end

  def start_lease(conn, id, ttl) do
    channel = lookup_channel(conn)
    grant_request = Etcdserverpb.LeaseGrantRequest.new(ID: id, TTL: ttl)
    response = Etcdserverpb.Lease.Stub.lease_grant(channel, grant_request)
    response

  end

  def keep_lease_alive(conn, id) do
    channel = lookup_channel(conn)
    EtcdClient.StreamSupervisor.start_child(channel, id, EtcdClient.Lease)


  end

  def keep_alive_loop(stream, id) do
    live_request = Etcdserverpb.LeaseKeepAliveRequest.new(ID: id)
    GRPC.Client.Stream.send_request(stream, live_request, end_stream: false, timeout: :infinity)
    :timer.sleep(1000)
    keep_alive_loop(stream, id)
  end

end
