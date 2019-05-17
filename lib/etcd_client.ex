defmodule EtcdClient do

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link(opts) do
    channel = get_connection(opts.host, opts.port)
    Registry.register(:etcd_registry, opts.name, channel)
  end

  def get_connection(host, port) do
    {:ok, channel} = GRPC.Stub.connect(host <> ":" <> port,adapter_opts: %{http2_opts: %{keepalive: :infinity}})
    channel
  end

  def close_connection(conn) do
    channel = lookup_channel(conn)
    GRPC.Stub.disconnect(channel)
    Registry.unregister(:etcd_registry, conn)
  end

  defp lookup_channel(conn) do
    channel = elem(Enum.fetch!(Registry.lookup(:etcd_registry, conn), 0),1)
  end

  def put_kv_pair(conn, key, value) do
    channel = lookup_channel(conn)
    request = Etcdserverpb.PutRequest.new(key: key, value: value, prev_kv: true)
    {:ok, response} = Etcdserverpb.KV.Stub.put(channel,request)
    response
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

  def start_watcher(conn, id) do
    channel = lookup_channel(conn)
    EtcdClient.StreamSupervisor.start_child(channel, id, EtcdClient.Watcher)

  end

  def add_watch(start_key, end_key, watcher_id, watch_id, from) do
    watch_create_request = Etcdserverpb.WatchCreateRequest.new(key: start_key, range_end: end_key, prev_kv: true, progress_notify: true, watch_id: watch_id)
    GenServer.cast(EtcdClient.Watcher.via_tuple(watcher_id), {:add_watch, watch_create_request, from})
  end

  def send_watch_event(pid, event)do
    Process.send(pid, {:watch_event, event}, [])
  end

end
