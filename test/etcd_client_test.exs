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
    request = Etcdserverpb.PutRequest.new(key: "foo", value: "coo", prev_kv: true)
    response = EtcdClient.put_kv_pair(ETCD, request)
    assert elem(response, 1).prev_kv.key == "foo"
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

  test "get, delete kv range" do
    EtcdClient.start_link([hostname: "localhost", port: "2379", name: ETCD])
    EtcdClient.put_kv_pair(ETCD, "foo", "bar")
    EtcdClient.put_kv_pair(ETCD, "foo1", "bar")
    {:ok, response} = EtcdClient.get_kv_range(ETCD, "foo", "foo2")
    assert Enum.fetch!(response.kvs, 0).value == "bar"
    assert Enum.fetch!(response.kvs, 1).value == "bar"
    request = Etcdserverpb.RangeRequest.new(key: "foo", range_end: "foo1", limit: 1)
    {:ok, response} = EtcdClient.get_kv_range(ETCD, request)
    assert length(response.kvs) == 1
    EtcdClient.delete_kv_range(ETCD, "foo", "foo1")
    {:ok, response} = EtcdClient.get_kv_range(ETCD, "foo", "foo1")
    assert length(response.kvs) == 0
    EtcdClient.put_kv_pair(ETCD, "foo", "bar")
    EtcdClient.put_kv_pair(ETCD, "foo1", "bar")
    delete_request = Etcdserverpb.DeleteRangeRequest.new(key: "foo", range_end: "foo1", prev_kv: true)
    EtcdClient.delete_kv_range(ETCD, delete_request)
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

  test "start, end a lease" do
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

  test "lease leases" do
    EtcdClient.start_link([hostname: "localhost", port: "2379", name: ETCD])
    {:ok, response} = EtcdClient.start_lease(ETCD, 1, 10)
    {:ok, response} = EtcdClient.start_lease(ETCD, 2, 10)
    {:ok, response} = EtcdClient.start_lease(ETCD, 3, 10)
    {:ok, response} = EtcdClient.get_leases(ETCD)
    assert length(response.leases) == 3
  end

  test "add, cancel, listen to a watch" do
    EtcdClient.start_link([hostname: "localhost", port: "2379", name: ETCD])
    EtcdClient.start_watcher(ETCD, "watcher1", self())
    EtcdClient.add_watch("foo", "\0", "watcher1", 1)
    event = listen()
    assert elem(event, 1).created == true
    assert elem(event, 1).watch_id == 1
    EtcdClient.add_watch("boo", "\0", "watcher1", 2)
    event = listen()
    assert elem(event, 1).created == true
    assert elem(event, 1).watch_id == 2
    EtcdClient.cancel_watch("watcher1", 2)
    event = listen()
    assert elem(event, 1).canceled == true
    assert elem(event, 1).watch_id == 2
    EtcdClient.put_kv_pair(ETCD, "foo", "bar")
    event = listen()
    assert Enum.fetch!(elem(event, 1).events, 0).type == :PUT
    assert elem(event, 1).watch_id == 1
    EtcdClient.delete_kv_pair(ETCD, "foo")
    event = listen()
    assert Enum.fetch!(elem(event, 1).events, 0).type == :DELETE
    assert elem(event, 1).watch_id == 1
    response = EtcdClient.kill_watcher("watcher1")
    assert response == :ok
    response = EtcdClient.kill_watcher("watcher1")
    assert response == {:error, "No process associated with watcher_id"}
    EtcdClient.close_connection(ETCD)
  end

  test "add watch with all options" do
    EtcdClient.start_link([hostname: "localhost", port: "2379", name: ETCD])
    EtcdClient.start_watcher(ETCD, "watcher1", self())
    watch_create_request = Etcdserverpb.WatchCreateRequest.new(watch_id: 1, key: "foo", range_end: "\0",
                                                               prev_kv: true, progress_notify: true,
                                                               start_revision: 0, filters: [:NOPUT], fragment: false)
    EtcdClient.add_watch("watcher1", watch_create_request)
    event = listen()
    assert elem(event, 1).created == true
    assert elem(event, 1).watch_id == 1
    EtcdClient.put_kv_pair(ETCD, "foo", "bar")
    EtcdClient.delete_kv_pair(ETCD, "foo")
    event = listen()
    assert Enum.fetch!(elem(event, 1).events, 0).type == :DELETE


  end

  def listen() do
    receive do
      {:watch_event, event} ->
        event
    end
  end
end
