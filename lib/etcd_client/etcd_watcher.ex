defmodule EtcdClient.Watcher do
  use GenServer

  @type t :: %__MODULE__{
    stream: GRPC.Server.Stream.t(),
    channel: GRPC.Channel.t(),
    watcher_id: term(),
    callback_pid: pid()
  }

  defstruct stream: nil,
            channel: nil,
            watcher_id: nil,
            callback_pid: nil

  def start_link(args) do
    GenServer.start_link(__MODULE__, [args], name: via_tuple(args[:id]))
  end

  @impl true
  def init([args]) do
    {:ok, %__MODULE__{channel: args[:channel], watcher_id: args[:id], callback_pid: args[:callback_pid]}}
  end

  defp via_tuple(watcher_id) do
    {:via, Registry, {:etcd_registry, watcher_id}}
  end

  @impl true
  def handle_call(:get_stream, _from, state) do
    {:reply, {:ok, state.stream}, state}
  end

  @impl true
  def handle_call({:set_stream, stream}, _from, state) do
    {:reply, :ok, %__MODULE__{state | stream: stream}}
  end

  @impl true
  def handle_call(:stop, _from, state) do
    {:stop, :normal, :ok, state}
  end

  @impl true
  def handle_call(:start_listener, from, state) do
    #EtcdClient.WatchListener.start_link/1 will call GenServer.reply/2 itself
    #so it's very important that this method returns a :noreply

    {:ok, _pid} = EtcdClient.WatchListener.start_link([channel: state.channel, watcher: state.watcher_id, from: from])
    {:noreply, state}
  end

  @impl true
  def handle_cast({:send_watch_event, event}, state) do
    Process.send(state.callback_pid, {:watch_event, event}, [])
    {:noreply, state}
  end

  @impl true
  def handle_cast({:add_watch, watch_request}, state) do
    GRPC.Client.Stream.send_request(state.stream, watch_request, end_stream: false, timeout: :infinity)
    {:noreply, state}
  end

  # These next two ominous handle_info calls are here because... ???
  # I'm too afraid to delete them
  @impl true
  def handle_info({:gun_data, _pid, _ref, _test, _data}, state) do
    {:noreply, state}
  end

  @impl true
  def handle_info({:gun_response, _pid, _ref, _test, _data, _test1}, state) do
    {:noreply, state}
  end

  @spec send_watch_event(term(), Etcdserverpb.WatchResponse.t()) :: :ok
  def send_watch_event(watcher_id, event) do
    GenServer.cast(via_tuple(watcher_id), {:send_watch_event, event})
  end

  @spec set_stream(term(), GRPC.Server.Stream.t()) :: :ok
  def set_stream(watcher_id, stream) do
    GenServer.call(via_tuple(watcher_id), {:set_stream, stream})
  end

  @spec get_stream(term()) :: {:ok, GRPC.Server.Stream.t()}
  def get_stream(watcher_id) do
    GenServer.call(via_tuple(watcher_id), :get_stream)
  end

  @spec send_watch_request(Etcdserverpb.WatchRequest.t(), term()) :: :ok
  def send_watch_request(watch_request, watcher_id) do
    GenServer.cast(via_tuple(watcher_id), {:add_watch, watch_request})
  end

  @spec start_listener(term()) :: {:ok, GRPC.Server.Stream.t()}
  def start_listener(watcher_id) do
    {:ok, stream} = ret_tup = GenServer.call(via_tuple(watcher_id), :start_listener)
    :ok = set_stream(watcher_id, stream)
    ret_tup
  end

  @spec kill_watcher(term()) :: :ok
  def kill_watcher(watcher_id) do
    GenServer.call(via_tuple(watcher_id), :stop)
  end

end


