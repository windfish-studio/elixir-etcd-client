defmodule EtcdClient.StreamSupervisor do
  # Automatically defines child_spec/1
  use DynamicSupervisor

  def start_link(arg) do
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def start_child(channel, id, module) do
    child = %{
      id: Integer.to_string(id),
      start: {module, :start_link, [%{channel: channel, id: id}]}
    }

    DynamicSupervisor.start_child(__MODULE__, child)
  end

  @impl true
  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end



end
