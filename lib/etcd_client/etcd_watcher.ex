defmodule EtcdClient.Watcher do
  use GenServer

  @type t :: %__MODULE__{
    stream: GRPC.Server.Stream.t(),
    channel: GRPC.Server.Channel.t(),
    watcher_id: String.t(),
    from: pid
  }

  defstruct stream: nil,
            channel: nil,
            watcher_id: nil,
            from: nil

  def start_link(args) do
    GenServer.start_link(__MODULE__, [args], name: via_tuple(args[:id]))
  end

  @impl true
  def init([args]) do
    {:ok, %__MODULE__{channel: args[:channel], watcher_id: args[:id], from: args[:from]}}
  end

  defp via_tuple(watcher_id) do
    {:via, Registry, {:etcd_registry, watcher_id}}
  end

  @impl true
  def handle_call(:get_stream, from, state) do
    {:reply, state.stream, state}
  end

  @impl true
  def handle_call({:set_stream, stream}, _from, state) do
    {:reply, state, %__MODULE__{state | stream: stream}}
  end

  @impl true
  def handle_call(:kill_me, _from, state) do
    {:stop, :normal, :dead, state}
  end

  @impl true
  def handle_call(:start_listener, from, state) do
    EtcdClient.WatchListener.start_link([channel: state.channel, watcher: state.watcher_id, from: from])
    {:noreply, state}
  end

  @impl true
  def handle_cast({:send_watch_event, event}, state) do
    Process.send(state.from, {:watch_event, event}, [])
    {:noreply, state}
  end

  @impl true
  def handle_cast({:add_watch, watch_request}, state) do
    GRPC.Client.Stream.send_request(state.stream, watch_request, end_stream: false, timeout: :infinity)
    {:noreply, state}
  end

  @impl true
  def handle_info({:gun_data, _pid, _ref, _test, _data}, state) do
    {:noreply, state}
  end

  @impl true
  def handle_info({:gun_response, _pid, _ref, _test, _data, _test1}, state) do
    {:noreply, state}
  end

  def send_watch_event(watcher_id, event)do
    GenServer.cast(via_tuple(watcher_id), {:send_watch_event, event})
  end

  def set_stream(watcher_id, stream) do
    GenServer.call(via_tuple(watcher_id), {:set_stream, stream})
  end

  def get_stream(watcher_id) do
    GenServer.call(via_tuple(watcher_id), :get_stream)
  end

  def send_watch_request(watch_request, watcher_id) do
    GenServer.cast(via_tuple(watcher_id), {:add_watch, watch_request})
  end

  def start_listener(watcher_id) do
    stream = GenServer.call(via_tuple(watcher_id), :start_listener)
    set_stream(watcher_id, stream)
  end

  def kill_watcher(watcher_id) do
    GenServer.call(via_tuple(watcher_id), :kill_me)
  end

end


