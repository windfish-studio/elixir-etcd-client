defmodule EtcdClientTest do
  use ExUnit.Case
  doctest EtcdClient

  test "greets the world" do
    assert EtcdClient.hello() == :world
  end
end
