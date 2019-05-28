defmodule EtcdClientTest do
  use ExUnit.Case
  doctest EtcdClient

  test "start" do
    response = EtcdClient.start_link([hostname: "localhost", port: "2379", name: ETCD])
    assert elem(response, 0) == :ok
    EtcdClient.close_connection(ETCD)
  end

  test "close connection" do
   EtcdClient.start_link([hostname: "localhost", port: "2379", name: ETCD])
   test = EtcdClient.close_connection(ETCD)
   assert test == :ok
  end

  test "put kv pair" do
    EtcdClient.start_link([hostname: "localhost", port: "2379", name: ETCD])
    response = EtcdClient.put_kv_pair(ETCD, "foo", "bar")
    assert elem(response, 0) == :ok
    EtcdClient.delete_kv_pair(ETCD, "foo")
    EtcdClient.close_connection(ETCD)
  end

  test "get kv pair" do
    EtcdClient.start_link([hostname: "localhost", port: "2379", name: ETCD])
    EtcdClient.put_kv_pair(ETCD, "foo", "bar")
    {:ok, response} = EtcdClient.get_kv_pair(ETCD, "foo")
    assert Enum.fetch!(response.kvs, 0).value == "bar"
    EtcdClient.delete_kv_pair(ETCD, "foo")
    EtcdClient.close_connection(ETCD)
  end

  test "get/delete kv range" do
    EtcdClient.start_link([hostname: "localhost", port: "2379", name: ETCD])
    EtcdClient.put_kv_pair(ETCD, "foo", "bar")
    EtcdClient.put_kv_pair(ETCD, "foo1", "bar")
    {:ok, response} = EtcdClient.get_kv_range(ETCD, "foo", "foo2")
    assert Enum.fetch!(response.kvs, 0).value == "bar"
    assert Enum.fetch!(response.kvs, 1).value == "bar"
    EtcdClient.delete_kv_range(ETCD, "foo", "foo1")
    {:ok, response} = EtcdClient.get_kv_range(ETCD, "foo", "foo1")
    assert length(response.kvs) == 0
    EtcdClient.close_connection(ETCD)
  end

  test "delete kv pair" do
    EtcdClient.start_link([hostname: "localhost", port: "2379", name: ETCD])
    EtcdClient.put_kv_pair(ETCD, "foo", "bar")
    {:ok, response} = EtcdClient.delete_kv_pair(ETCD, "foo")
    {:ok, response} = EtcdClient.get_kv_pair(ETCD, "foo")
    assert response.kvs == []
  end

  test "start/end a lease" do
    EtcdClient.start_link([hostname: "localhost", port: "2379", name: ETCD])
    {:ok, response} = EtcdClient.start_lease(ETCD, 1, 2)
    EtcdClient.keep_lease_alive(ETCD, 1, 1000)
    :timer.sleep(2000)
    EtcdClient.put_kv_pair(ETCD, "foo", "bar", 1)
    {:ok, response} = EtcdClient.get_kv_pair(ETCD, "foo")
    assert Enum.fetch!(response.kvs, 0).lease == 1
    EtcdClient.revoke_lease(ETCD, 1)
    EtcdClient.revoke_lease(ETCD, 2)
    {:ok, response} = EtcdClient.get_kv_pair(ETCD, "foo")
    assert response.kvs == []
    EtcdClient.delete_kv_pair(ETCD, "foo")
    EtcdClient.close_connection(ETCD)
  end

  test "add a watch" do
    EtcdClient.start_link([hostname: "localhost", port: "2379", name: ETCD])
    EtcdClient.start_watcher(ETCD, "watcher1")
    EtcdClient.add_watch("foo", "\0", "watcher1", 1)

    EtcdClient.add_watch("boo", "\0", "watcher1", 2)
    EtcdClient.listen_watcher("watcher1", self())
    EtcdClient.add_watch("coo", "\0", "watcher1", 3)
    listen(20)
    EtcdClient.delete_kv_pair(ETCD, "foo")
    EtcdClient.delete_kv_pair(ETCD, "boo")
    EtcdClient.close_connection(ETCD)
  end

  def listen(0) do

  end

  def listen(count) do
    receive do
      {:watch_event, event} ->
        assert elem(event, 0) == :ok
        IO.inspect(event)
        EtcdClient.put_kv_pair(ETCD, "foo", "bar")
        EtcdClient.put_kv_pair(ETCD, "boo", "bar")
    end
    listen(count - 1)
  end
end
