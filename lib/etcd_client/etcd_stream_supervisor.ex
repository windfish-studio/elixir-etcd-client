defmodule EtcdClient.StreamSupervisor do
  # Automatically defines child_spec/1
  use DynamicSupervisor

  def start_link(arg) do
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def start_lease(channel, id, keep_alive_interval, module) do
    child = %{
      id: id,
      start: {module, :start_link, [[channel: channel, id: id, keep_alive_interval: keep_alive_interval]]}
    }

    DynamicSupervisor.start_child(__MODULE__, child)
  end

  def start_watcher(channel, id, module) do
    child = %{
      id: id,
      start: {module, :start_link, [[channel: channel, id: id]]}
    }

    DynamicSupervisor.start_child(__MODULE__, child)
  end

  def kill_child(pid) do
    DynamicSupervisor.terminate_child(__MODULE__, pid)
  end

  @impl true
  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end



end
