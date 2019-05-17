defmodule EtcdClient.Watcher do
  use GenServer

  defstruct stream: nil,
            watcher_id: nil

  def start_link(args) do
    name = via_tuple(args.id)
    GenServer.start_link(__MODULE__, [args], name: name)
  end

  @impl true
  def init([args]) do
    stream = Etcdserverpb.Watch.Stub.watch(args.channel, timeout: :infinity)
    {:ok, %__MODULE__{ stream: stream, watcher_id: args.id}}
  end

  def via_tuple(watcher_id) do
    {:via, Registry, {:etcd_registry, watcher_id}}
  end

  def get_state(watcher_id) do
    GenServer.call(via_tuple(watcher_id), :get_state, 5000)
  end

  @impl true
  def handle_call(:get_state, _from,  state) do
    response = %{
      watcher_id: state.watcher_id,
      stream: state.stream
    }
    {:reply, response, state}
  end

  @impl true
  def handle_cast({:add_watch, watch_create_request, from}, state) do
    watch_request = Etcdserverpb.WatchRequest.new(request_union: {:create_request, watch_create_request})
    GRPC.Client.Stream.send_request(state.stream, watch_request, end_stream: false, timeout: :infinity)
    {:ok, replies} = GRPC.Stub.recv(state.stream, timeout: :infinity)
    Enum.each(replies, fn(reply) -> EtcdClient.send_watch_event(from, reply) end)
    {:noreply, replies}
  end

  @impl true
  def handle_info({:gun_data, _pid, _ref, _test, _data}, state) do
    {:noreply, state}
  end

  @impl true
  def handle_info({:gun_response, _pid, _ref, _test, _data, _test1}, state) do
    {:noreply, state}
  end

end
