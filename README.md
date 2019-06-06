# EtcdClient

**ETCD Client for elixir**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `etcd_client` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:etcd_client, "~> 0.1.0-alpha.1"}
  ]
end
```

## Usage

Opens a grpc connection channel to etcd with hostname and port provided in 'opts' keyword list.
Registers the channel with name provided in 'opts' keyword list.

To start from a supervisor:
add to config.exs:

```elixir
config :myapp,
  etcd: [
    hostname: "localhost",
    port: "2379"
  ]
```

Add to supervisor child list:

```elixir
{EtcdClient, [Keyword.put(Application.get_env(:myapp, :etcd), :name, ETCD)]}
```

To use above connection pass the name you provided as the 'conn' argument to EtcdClient functions:

```elixir
{:ok, response} = EtcdClient.put_kv_pair(ETCD, key, value)
```

To establish an etcd lease and associate a kv pair:

```elixir
{:ok, response} = EtcdClient.start_lease(ETCD, lease_id, time_to_live)
{:ok, pid} = EtcdClient.keep_lease_alive(ETCD, lease_id, keep_alive_interval)
{:ok, response} = EtcdClient.put_kv_pair(ETCD, key, value, lease_id)
```

To establish an etcd watch over a range of keys:

```elixir
{:ok, pid} = EtcdClient.start_watcher(ETCD, watcher_id, from)
EtcdClient.add_watch(start_range, end_range, watcher_id, watch_id)
```

Events recieved by the watcher will be sent to the pid provided in the from argument,
to retrieve them if using a GenServer add:

```elixir
def handle_info({:watch_event, event} , state) do
  watch_response = elem(event, 1)
  Enum.each(watch_response.events, fn(e) -> process_watch_event(e) end)
  {:noreply, 1}
end
```

If using the latest master branch of etcd (3.3+git) you can add multiple watches to the same
watcher.  Older versions will ignore the watch_id and you will need to start a separate
watcher(with unique ids) for each individual watch.

For more information on etcd request and response types see the generated proto files in /lib/priv
on github.

Documentation  can be found at [https://hexdocs.pm/etcd_client](https://hexdocs.pm/etcd_client).

