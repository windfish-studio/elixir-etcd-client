defmodule EtcdClient do

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, opts},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end
  @moduledoc """
    Opens a grpc connection channel to etcd with hostname and port provided in opts keyword list.
    Registers the channel with name provided in opts keyword list. Returns tuple in form of {:ok, pid}

    To start from a supervisor:
    add to config.exs:
      config :myapp,
        etcd: [
          hostname: "localhost",
          port: "2379"
        ]

    add to supervisor child list:
        {EtcdClient, [Keyword.put(Application.get_env(:myapp, :etcd), :name, ETCD)]}

    To use above connection pass the name you provided as the conn argument to EtcdClient functions:
        {:ok, response} = EtcdClient.put_kv_pair(ETCD, key, value)

    To establish an etcd lease and associate a kv pair:
        {:ok, response} = EtcdClient.start_lease(ETCD, lease_id, time_to_live)
        {:ok, pid} = EtcdClient.keep_lease_alive(ETCD, lease_id)
        {:ok, response} = EtcdClient.put_kv_pair(ETCD, key, value, lease_id)

    To establish an etcd watch over a range of keys:
        {:ok, pid} = EtcdClient.start_watcher(ETCD, watcher_id)
        EtcdClient.add_watch(start_range, end_range, watcher_id, watch_id, from)
      Events recieved by the watcher will be sent to the pid provided in the from argument,
      to retrieve them if using a GenServer add:
        def handle_info({:watch_event, event} , state) do
          watch_response = elem(event, 1)
          Enum.each(watch_response.events, fn(e) -> process_watch_event(e) end)
          {:noreply, 1}
        end
  """
  @spec start_link(keyword()) :: {:ok, pid} | {:error, String.t}
  def start_link(opts) do
    {:ok, channel} = get_connection(opts[:hostname],opts[:port])
    Registry.register(:etcd_registry, opts[:name], channel)
  end

  defp via_tuple(id) do
    {:via, Registry, {:etcd_registry, id}}
  end

  @spec get_connection(String.t, String.t) :: {:ok, GRPC.Channel.t()} | {:error, String.t}
  defp get_connection(host, port) do
    GRPC.Stub.connect(host <> ":" <> port,adapter_opts: %{http2_opts: %{keepalive: :infinity}})
  end
  @doc """
    Closes and unregisters the grpc connection registered under conn argument
  """
  @spec close_connection(String.t) :: :ok
  def close_connection(conn) do
    channel = lookup_channel(conn)
    GRPC.Stub.disconnect(channel)
    Registry.unregister(:etcd_registry, conn)
  end

  defp lookup_channel(conn) do
    channel = elem(Enum.fetch!(Registry.lookup(:etcd_registry, conn), 0),1)
  end
  @doc """
    Sends a put request to etcd on grpc channel registered under conn argument with key and value arguments
    as the key value pair to be put.
  """
  @spec put_kv_pair(String.t, String.t, String.t) :: {:ok, Etcdserverpb.PutResponse.t()} | {:error, GRPC.RPCError.t()}
  def put_kv_pair(conn, key, value) do
    channel = lookup_channel(conn)
    request = Etcdserverpb.PutRequest.new(key: key, value: value, prev_kv: true)
    Etcdserverpb.KV.Stub.put(channel,request)
  end
  @doc """
    Sends a PUT request to etcd on grpc channel registered under conn argument with key and value arguments
    as the key value pair to be put and assigined to the lease provided in lease_id argument.
  """
  @spec put_kv_pair(String.t, String.t, String.t, integer) :: {:ok, Etcdserverpb.PutResponse.t()} | {:error, GRPC.RPCError.t()}
  def put_kv_pair(conn, key, value, lease_id) do
    channel = lookup_channel(conn)
    request = Etcdserverpb.PutRequest.new(key: key, value: value, lease: lease_id, prev_kv: true)
    Etcdserverpb.KV.Stub.put(channel,request)
  end
  @doc """
    Sends a range request to etcd on grpc channel registered under conn argument. Returns the kv pair
    associated with the key argument if it exists.
  """
  @spec get_kv_pair(String.t, String.t) :: {:ok, Etcdserverpb.RangeResponse.t()} | {:error, GRPC.RPCError.t()}
  def get_kv_pair(conn, key) do
    channel = lookup_channel(conn)
    request = Etcdserverpb.RangeRequest.new(key: key)
    Etcdserverpb.KV.Stub.range(channel, request)
  end

  @doc """
    Sends a range request to etcd on grpc channel registered under conn argument. Returns the kv range
    between the key and range arguments if any exist.
  """
  @spec get_kv_range(String.t, String.t, String.t) :: {:ok, Etcdserverpb.RangeResponse.t()} | {:error, GRPC.RPCError.t()}
  def get_kv_range(conn, key, range) do
    channel = lookup_channel(conn)
    request = Etcdserverpb.RangeRequest.new(key: key, range_end: range)
    Etcdserverpb.KV.Stub.range(channel, request)
  end
  @doc """
    Sends a delete range request to etcd on grpc channel registered under conn argument deleting the kv pair
    associated with the key argument.
  """
  @spec delete_kv_pair(String.t, String.t) :: {:ok, Etcdserverpb.DeleteRangeResponse.t()} | {:error, GRPC.RPCError.t()}
  def delete_kv_pair(conn, key) do
    channel = lookup_channel(conn)
    delete_request = Etcdserverpb.DeleteRangeRequest.new(key: key, prev_kv: true)
    Etcdserverpb.KV.Stub.delete_range(channel, delete_request)
  end

  @doc """
    Sends a delete range request to etcd on grpc channel registered under conn argument deleting the kv range
    between the key and range arguments.
  """
  @spec delete_kv_range(String.t, String.t, String.t) :: {:ok, Etcdserverpb.DeleteRangeResponse.t()} | {:error, GRPC.RPCError.t()}
  def delete_kv_range(conn, key, range) do
    channel = lookup_channel(conn)
    delete_request = Etcdserverpb.DeleteRangeRequest.new(key: key, range_end: range, prev_kv: true)
    Etcdserverpb.KV.Stub.delete_range(channel, delete_request)
  end

  @doc """
    Sends a lease grant request to etcd on grpc channel registered under conn argument with id and time to live.
    Returns tuple in form of {:ok, etcd_lease_grant_response} | {:error, error}
  """
  @spec start_lease(String.t, integer, integer) :: {:ok, Etcdserverpb.LeaseGrantResponse.t()} | {:error, GRPC.RPCError.t()}
  def start_lease(conn, id, ttl) do
    channel = lookup_channel(conn)
    grant_request = Etcdserverpb.LeaseGrantRequest.new(ID: id, TTL: ttl)
    Etcdserverpb.Lease.Stub.lease_grant(channel, grant_request)
  end
  @doc """
    Adds an EtcdClient.Lease genserver to supervision tree. Lease genserver opens an etcd lease keep alive
    stream and sends keep alive requests for given lease id every keep_alive_interval in miliseconds
  """
  @spec keep_lease_alive(String.t, integer, integer) :: {:ok, pid}
  def keep_lease_alive(conn, id, keep_alive_interval) do
    channel = lookup_channel(conn)
    EtcdClient.StreamSupervisor.start_lease(channel, id, keep_alive_interval, EtcdClient.Lease)
  end
  @doc """
    Revokes an etcd lease with the given id and kills it's keep alive process if it exists
  """
  @spec revoke_lease(String.t, integer) :: {:ok, Etcdserverpb.LeaseRevokeResponse.t()} | {:error, GRPC.RPCError.t()}
  def revoke_lease(conn, id) do
    channel = lookup_channel(conn)
    name = "lease" <> Integer.to_string(id)
    revoke_request = Etcdserverpb.LeaseRevokeRequest.new(ID: id)
    cond do
      Registry.lookup(:etcd_registry, name) == [] ->
        Etcdserverpb.Lease.Stub.lease_revoke(channel, revoke_request)
      true ->
        pid = elem(Enum.fetch!(Registry.lookup(:etcd_registry, name), 0),0)
        EtcdClient.StreamSupervisor.kill_child(pid)
        Etcdserverpb.Lease.Stub.lease_revoke(channel, revoke_request)
    end
  end
  @doc """
    Adds an EtcdClient.Watcher genserver to supervision tree. Watch genserver opens an etcd watch stream
    that etcd watches can be added to. Watcher supports multiple etcd watches on a single stream. If more than
    one stream is needed start another Watcher with a different id.
  """
  @spec start_watcher(String.t, integer) :: {:ok, pid}
  def start_watcher(conn, id) do
    channel = lookup_channel(conn)
    EtcdClient.StreamSupervisor.start_watcher(channel, id, EtcdClient.Watcher)

  end
  @doc """
    Adds an etcd watch on key range to the Watcher with watcher_id. The watcher will send etcd watch events to the
    pid provided in the from argument.
  """
  @spec add_watch(String.t(), String.t(), String.t(), integer) :: :ok
  def add_watch(start_key, end_key, watcher_id, watch_id) do
    watch_create_request = Etcdserverpb.WatchCreateRequest.new(watch_id: watch_id, key: start_key, range_end: end_key, prev_kv: true, progress_notify: true)
    GenServer.cast(EtcdClient.Watcher.via_tuple(watcher_id), {:add_watch, watch_create_request})
  end
  @spec listen_watcher(String.t, pid) :: :ok
  def listen_watcher(watcher_id, from) do
    GenServer.cast(EtcdClient.Watcher.via_tuple(watcher_id), {:listen, from})
  end
  @doc """
    Sends etcd watch events to the given pid
  """
  @spec send_watch_event(pid, Mvccpb.Event.t()) :: :ok
  def send_watch_event(pid, event)do
    Process.send(pid, {:watch_event, event}, [])
  end

end
