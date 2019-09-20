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
    This module provides basic ETCD watch, lease, and kv functionality, it is incomplete and still in development.

    Opens a grpc connection channel to etcd with hostname and port provided in 'opts' keyword list.
    Registers the channel with name provided in 'opts' keyword list.

    To start from a supervisor:
    add to config.exs:
      config :myapp,
        etcd: [
          hostname: "localhost",
          port: "2379"
        ]

    Add to supervisor child list:
        {EtcdClient, [Keyword.put(Application.get_env(:myapp, :etcd), :name, ETCD)]}

    To use above connection pass the name you provided as the 'conn' argument to EtcdClient functions:
        {:ok, response} = EtcdClient.put_kv_pair(ETCD, key, value)

    To establish an etcd lease and associate a kv pair:
        {:ok, response} = EtcdClient.start_lease(ETCD, lease_id, time_to_live)
        {:ok, pid} = EtcdClient.keep_lease_alive(ETCD, lease_id, keep_alive_interval)
        {:ok, response} = EtcdClient.put_kv_pair(ETCD, key, value, lease_id)

    To establish an etcd watch over a range of keys:
        {:ok, pid} = EtcdClient.start_watcher(ETCD, watcher_id, from)
        EtcdClient.add_watch(start_range, end_range, watcher_id, watch_id)
    Events recieved by the watcher will be sent to the pid provided in the from argument,
    to retrieve them if using a GenServer add:
        def handle_info({:watch_event, event} , state) do
          watch_response = elem(event, 1)
          Enum.each(watch_response.events, fn(e) -> process_watch_event(e) end)
          {:noreply, 1}
        end
    If using the latest master branch of etcd (3.3+git) you can add multiple watches to the same
    watcher.  Older versions will ignore the watch_id and you will need to start a separate
    watcher(with unique ids) for each individual watch.

    For more information on etcd request and response types see the generated proto files in /lib/priv
    on github.
  """
  @spec start_link(keyword()) :: {:ok, pid} | {:error, String.t}
  def start_link(opts) do
    {:ok, channel} = get_connection(opts[:hostname],opts[:port])
    Registry.register(:etcd_registry, opts[:name], channel)
  end

  @spec get_connection(String.t(), String.t()) :: {:ok, GRPC.Channel.t()} | {:error, String.t()}
  defp get_connection(host, port) do
    GRPC.Stub.connect(host <> ":" <> port,adapter_opts: %{http2_opts: %{keepalive: :infinity}})
  end
  @doc """
    Closes and unregisters the grpc connection registered under 'conn'
  """
  @spec close_connection(term()) :: :ok
  def close_connection(conn) do
    channel = lookup_channel(conn)
    GRPC.Stub.disconnect(channel)
    Registry.unregister(:etcd_registry, conn)
  end

  defp lookup_channel(conn) do
    [{_pid, channel}] = Registry.lookup(:etcd_registry, conn)
    channel
  end
  @doc """
    Sends a put request to etcd on grpc channel registered under 'conn' with 'key' and 'value'
    as the key value pair to be put. Returns {:ok, %{key, value}}
  """
  @spec put_kv_pair(conn :: term(), key :: binary(), value :: binary()) :: {:ok, map()} | {:error, GRPC.RPCError.t()}
  def put_kv_pair(conn, key, value) do
    channel = lookup_channel(conn)
    request = Etcdserverpb.PutRequest.new(key: key, value: value)
    response = Etcdserverpb.KV.Stub.put(channel,request)
    case response do
      {:ok, _return} ->
        {:ok, %{key: key, value: value}}
      {:error, _error} ->
        response
    end
  end
  @doc """
    Sends a PUT request to etcd on grpc channel registered under 'conn' with 'key' and 'value'
    as the key value pair to be put and assigined to the lease provided in 'lease_id'
    Returns {:ok, %{key, value, lease}}
  """
  @spec put_kv_pair(term(), binary(), binary(), integer) :: {:ok, map()} | {:error, GRPC.RPCError.t()}
  def put_kv_pair(conn, key, value, lease_id) do
    channel = lookup_channel(conn)
    request = Etcdserverpb.PutRequest.new(key: key, value: value, lease: lease_id)
    response = Etcdserverpb.KV.Stub.put(channel,request)
    case response do
      {:ok, %{header: %{revision: rev}}} ->
        {:ok, %{key: key, value: value, lease: lease_id, rev: rev}}
      {:error, _error} ->
        response
    end
  end
  @doc """
    Sends a PUT request to etcd with provided 'put_request' and returns full put response.  Use this function if you
    need prev_kv data or the full put response
  """
  @spec put_kv_pair(term(), Etcdserverpb.PutRequest.t()) :: {:ok, Etcdserverpb.PutResponse.t()} | {:error, GRPC.RPCError.t()}
  def put_kv_pair(conn, put_request) do
    channel = lookup_channel(conn)
    Etcdserverpb.KV.Stub.put(channel, put_request)
  end
  @doc """
    Sends a range request to etcd on grpc channel registered under 'conn'. Returns the kv pair
    associated with 'key' if it exists in the form of a list of key/value/lease maps
  """
  @spec get_kv_pair(term(), binary()) :: {:ok, list()} | {:error, GRPC.RPCError.t()}
  def get_kv_pair(conn, key) do
    channel = lookup_channel(conn)
    request = Etcdserverpb.RangeRequest.new(key: key)
    response = Etcdserverpb.KV.Stub.range(channel, request)
    case response do
      {:ok, return} ->
        {:ok, Enum.map(return.kvs, fn(kv) ->
          %{key: kv.key, value: kv.value, lease: kv.lease, rev: kv.mod_revision}
        end)}
      {:error, _error} ->
        response
    end
  end

  @doc """
    Sends a range request to etcd on grpc channel registered under 'conn'. Returns the kv range
    between 'key' and 'range' if any exist in the form of a list of key/value/lease maps
  """
  @spec get_kv_range(term(), binary(), binary()) :: {:ok, list()} | {:error, GRPC.RPCError.t()}
  def get_kv_range(conn, key, range) do
    channel = lookup_channel(conn)
    request = Etcdserverpb.RangeRequest.new(key: key, range_end: range)
    response = Etcdserverpb.KV.Stub.range(channel, request)
    case response do
      {:ok, return} ->
        {:ok, Enum.map(return.kvs, fn(kv) ->
          %{key: kv.key, value: kv.value, lease: kv.lease, rev: kv.mod_revision}
        end)}
      {:error, _error} ->
        response
    end
  end
  @doc """
    Sends a range request to etcd using provided 'range_request' and returns the full etcd range response.
    Use this function if you need the full range response
  """
  @spec get_kv_range(term(), Etcdserverpb.RangeRequest.t()) :: {:ok, Etcdserverpb.RangeResponse.t()} | {:error, GRPC.RPCError.t()}
  def get_kv_range(conn, range_request) do
    channel = lookup_channel(conn)
    Etcdserverpb.KV.Stub.range(channel, range_request)
  end
  @doc """
    Sends a delete range request to etcd on grpc channel registered under 'conn' deleting the kv pair
    associated with 'key'. Returns {:ok, number_off_keys_deleted}
  """
  @spec delete_kv_pair(term(), binary()) :: {:ok, integer()} | {:error, GRPC.RPCError.t()}
  def delete_kv_pair(conn, key) do
    channel = lookup_channel(conn)
    delete_request = Etcdserverpb.DeleteRangeRequest.new(key: key)
    response = Etcdserverpb.KV.Stub.delete_range(channel, delete_request)
    case response do
      {:ok, return} ->
        {:ok, return.deleted}
      {:error, _error} ->
        response
    end
  end

  @doc """
    Sends a delete range request to etcd on grpc channel registered under 'conn' deleting the kv range
    between 'key' and 'range'. Returns {:ok, number_of_keys_deleted}
  """
  @spec delete_kv_range(term(), binary(), binary()) :: {:ok, integer()} | {:error, GRPC.RPCError.t()}
  def delete_kv_range(conn, key, range) do
    channel = lookup_channel(conn)
    delete_request = Etcdserverpb.DeleteRangeRequest.new(key: key, range_end: range)
    response = Etcdserverpb.KV.Stub.delete_range(channel, delete_request)
    case response do
      {:ok, return} ->
        {:ok, return.deleted}
      {:error, _error} ->
        response
    end
  end
  @doc """
    Sends a delete range request to etcd using provided 'delete_range_request' and returns the full delete range response.
    Use this function if you need the full response
  """
  @spec delete_kv_range(term(), Etcdserverpb.DeleteRangeRequest.t()) :: {:ok, Etcdserverpb.DeleteRangeResponse.t()} | {:error, GRPC.RPCError.t()}
  def delete_kv_range(conn, delete_range_request) do
    channel = lookup_channel(conn)
    Etcdserverpb.KV.Stub.delete_range(channel, delete_range_request)
  end

  @doc """
    Sends a lease grant request to etcd on grpc channel registered under 'conn' with 'id' and time to live 'ttl'
    Returns {:ok, %{lease_id, lease_ttl, error}}
  """
  @spec start_lease(term(), integer(), integer()) :: {:ok, map()} | {:error, GRPC.RPCError.t()}
  def start_lease(conn, id, ttl) do
    channel = lookup_channel(conn)
    grant_request = Etcdserverpb.LeaseGrantRequest.new(ID: id, TTL: ttl)
    response = Etcdserverpb.Lease.Stub.lease_grant(channel, grant_request)
    case response do
      {:ok, return} ->
        {:ok, %{lease_id: Map.get(return, :ID), lease_ttl: Map.get(return, :TTL), error: return.error}}
      {:error, _error} ->
        response
    end
  end

  @doc """
    Sends a lease grant request to etcd on grpc channel registered under 'conn' with time to live 'ttl'
    Returns {:ok, %{lease_id, lease_ttl, error}}
  """
  @spec start_lease(term(), integer()) :: {:ok, map()} | {:error, GRPC.RPCError.t()}
  def start_lease(conn, ttl) do
    channel = lookup_channel(conn)
    grant_request = Etcdserverpb.LeaseGrantRequest.new(TTL: ttl)
    response = Etcdserverpb.Lease.Stub.lease_grant(channel, grant_request)
    case response do
      {:ok, return} ->
        {:ok, %{lease_id: Map.get(return, :ID), lease_ttl: Map.get(return, :TTL), error: return.error}}
      {:error, _error} ->
        response
    end
  end
  @doc """
    Starts an EtcdClient.Lease. EtcdClient.Lease opens an etcd lease keep alive
    stream and sends keep alive requests for given 'id' every 'keep_alive_interval' in miliseconds
  """
  @spec keep_lease_alive(term(), integer(), integer()) :: {:ok, pid}
  def keep_lease_alive(conn, id, keep_alive_interval) do
    channel = lookup_channel(conn)
    EtcdClient.Lease.start_link([channel: channel, id: id, keep_alive_interval: keep_alive_interval])
  end
  @doc """
    Revokes an etcd lease with the given 'id' and kills it's keep alive process if it exists
  """
  @spec revoke_lease(term(), integer()) :: {:ok, :revoked} | {:error, GRPC.RPCError.t()}
  def revoke_lease(conn, id) do
    channel = lookup_channel(conn)
    name = "lease" <> Integer.to_string(id)
    revoke_request = Etcdserverpb.LeaseRevokeRequest.new(ID: id)
    cond do
      Registry.lookup(:etcd_registry, name) == [] ->
        Etcdserverpb.Lease.Stub.lease_revoke(channel, revoke_request)
        {:ok, :revoked}
      true ->
        pid = elem(Enum.fetch!(Registry.lookup(:etcd_registry, name), 0),0)
        send(pid, :kill_me)
        Etcdserverpb.Lease.Stub.lease_revoke(channel, revoke_request)
        {:ok, :revoked}
    end
  end
  @doc """
    Returns all active leases on the given etcd 'conn' as a list of lease_ids
  """
  @spec get_leases(term()) :: {:ok, list()} | {:error, GRPC.RPCError.t()}
  def get_leases(conn) do
    channel = lookup_channel(conn)
    leases_request = Etcdserverpb.LeaseLeasesRequest.new()
    response = Etcdserverpb.Lease.Stub.lease_leases(channel, leases_request)
    case response do
      {:ok, return} ->
        {:ok, Enum.map(return.leases, fn(lease) ->
          Map.get(lease, :ID)
        end)}
      {:error, _error} ->
        response
    end
  end
  @doc """
    Starts an EtcdClient.Watcher with the given 'id'. Opens an etcd watch stream
    that etcd watches can be added to. EtcdClient.Watcher supports multiple etcd watches on a single stream. If more than
    one stream is needed start another EtcdClient.Watcher with a different id.  Watch events will be sent to the pid provided
    in the from argument.
  """
  @spec start_watcher(term(), term(), pid()) :: {:ok, GRPC.Server.Stream.t()}
  def start_watcher(conn, id, from) do
    channel = lookup_channel(conn)
    EtcdClient.Watcher.start_link([channel: channel, id: id, callback_pid: from])
    EtcdClient.Watcher.start_listener(id)
  end
  @doc """
    Adds an etcd watch on key range to the EtcdClient.Watcher with given 'watcher_id'. Function to start a basic watch
    with default etcd options
  """
  @spec add_watch(binary(), binary(), term(), integer()) :: :ok
  def add_watch(start_key, end_key, watcher_id, watch_id) do
    watch_create_request = Etcdserverpb.WatchCreateRequest.new(watch_id: watch_id, key: start_key, range_end: end_key)
    watch_request = Etcdserverpb.WatchRequest.new(request_union: {:create_request, watch_create_request})
    EtcdClient.Watcher.send_watch_request(watch_request, watcher_id)
  end
  @doc """
    Adds a watch to EtcdClient.Watcher with given 'watcher_id' using provided 'watch_create_request'
  """
  @spec add_watch(term(), Etcdserverpb.WatchCreateRequest.t()) :: :ok
  def add_watch(watcher_id, watch_create_request) do
    watch_request = Etcdserverpb.WatchRequest.new(request_union: {:create_request, watch_create_request})
    EtcdClient.Watcher.send_watch_request(watch_request, watcher_id)
  end
  @doc """
    Sends a watch cancel request to etcd on the stream for provided 'watcher_id' to cancel the watch
    with provided 'watch_id'
  """
  @spec cancel_watch(term(), integer()) :: :ok
  def cancel_watch(watcher_id, watch_id) do
    watch_cancel_request = Etcdserverpb.WatchCancelRequest.new(watch_id: watch_id)
    watch_request = Etcdserverpb.WatchRequest.new(request_union: {:cancel_request, watch_cancel_request})
    EtcdClient.Watcher.send_watch_request(watch_request, watcher_id)
  end

  @spec add_lock(term(), binary(), integer()) :: {:ok, V3lockpb.LockResponse.t()}
  def add_lock(conn, name, lease_id) do
    channel = lookup_channel(conn)
    request = V3lockpb.LockRequest.new(name: name, lease: lease_id)
    V3lockpb.Lock.Stub.lock(channel, request, timeout: :infinity)
  end

  @spec kill_watcher(term()) :: :ok | {:error, String.t()}
  def kill_watcher(watcher_id) do
    cond do
      Registry.lookup(:etcd_registry, watcher_id) == [] ->
        {:error, "No process associated with watcher_id"}
      true ->
        EtcdClient.Watcher.kill_watcher(watcher_id)
    end
  end

end
