defmodule EtcdClient.Lease do
  use GenServer



  def start_link(args) do
    GenServer.start_link(__MODULE__, [args])
  end

  @impl true
  def init([args]) do
    stream = Etcdserverpb.Lease.Stub.lease_keep_alive(args.channel, timeout: :infinity)
    spawn fn -> keep_alive_loop(stream, args.id) end
  end

  @impl true
  def handle_info({:gun_data, _pid, _ref, _test, _data}, state) do
    {:noreply, state}
  end

  def keep_alive_loop(stream, id) do
    live_request = Etcdserverpb.LeaseKeepAliveRequest.new(ID: id)
    GRPC.Client.Stream.send_request(stream, live_request, end_stream: false, timeout: :infinity)
    :timer.sleep(1000)
    keep_alive_loop(stream, id)
  end

end
