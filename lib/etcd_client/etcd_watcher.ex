defmodule EtcdClient.Watcher do
  use GenServer

  @type t :: %__MODULE__{
    stream: GRPC.Server.Stream.t(),
    watcher_id: String.t(),
    from: pid
  }

  defstruct stream: nil,
            watcher_id: nil,
            from: nil

  def start_link(args) do
    GenServer.start_link(__MODULE__, [args])
  end

  @impl true
  def init([args]) do
    stream = Etcdserverpb.Watch.Stub.watch(args[:channel], timeout: :infinity)
    Registry.register(:etcd_registry, args[:id], stream)
    send(self(), :listen)
    {:ok, %__MODULE__{ stream: stream, watcher_id: args[:id], from: args[:from]}}
  end

  @impl true
  def handle_info(:listen, state) do
    {:ok, replies} = GRPC.Stub.recv(state.stream, timeout: :infinity)
    Enum.each(replies, fn(reply) -> send_watch_event(state.from, reply) end)
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

  defp send_watch_event(pid, event)do
    Process.send(pid, {:watch_event, event}, [])
  end

end


