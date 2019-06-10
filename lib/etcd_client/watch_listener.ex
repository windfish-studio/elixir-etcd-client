defmodule EtcdClient.WatchListener do
  use Task

  def start_link(args) do
    Task.start_link(__MODULE__, :run, [args])
  end

  def run(args) do
    stream = Etcdserverpb.Watch.Stub.watch(args[:channel], timeout: :infinity)
    GenServer.reply(args[:from], stream)
    {:ok, replies} = GRPC.Stub.recv(stream, timeout: :infinity)
    Enum.each(replies, fn(reply) -> EtcdClient.Watcher.send_watch_event(args[:watcher], reply) end)
  end
end
