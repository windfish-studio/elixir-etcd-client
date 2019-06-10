defmodule EtcdClient.Lease do
  use GenServer

  @type t :: %__MODULE__{
    stream: GRPC.Server.Stream.t(),
    lease_id: integer,
    keep_alive_interval: integer
  }

  defstruct stream: nil,
            lease_id: nil,
            keep_alive_interval: nil

  def start_link(args) do
    GenServer.start_link(__MODULE__, [args])
  end

  @impl true
  def init([args]) do
    stream = Etcdserverpb.Lease.Stub.lease_keep_alive(args[:channel], timeout: :infinity)
    name = "lease" <> Integer.to_string(args[:id])
    Registry.register(:etcd_registry, name, args[:id])
    send(self(), :keep_alive)
    {:ok, %__MODULE__{ stream: stream, lease_id: args[:id], keep_alive_interval: args[:keep_alive_interval]}}
  end

  @impl true
  def handle_info(:kill_me, state) do
    {:stop, :normal, state}
  end

  @impl true
  def handle_info({:gun_data, _pid, _ref, _test, _data}, state) do
    {:noreply, state}
  end

  @impl true
  def handle_info({:gun_response, _pid, _ref, _test, _data, _test1}, state) do
    {:noreply, state}
  end

  @impl true
  def handle_info(:keep_alive, state) do
    live_request = Etcdserverpb.LeaseKeepAliveRequest.new(ID: state.lease_id)
    GRPC.Client.Stream.send_request(state.stream, live_request, end_stream: false, timeout: :infinity)
    send(self(), :schedule_keep_alive)
    {:noreply, state}
  end

  def handle_info(:schedule_keep_alive, state) do
    Process.send_after(self(), :keep_alive, state.keep_alive_interval)
    {:noreply, state}
  end

end
