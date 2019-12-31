defmodule Rpcpb.Request do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          Operation: atom | integer,
          Member: Rpcpb.Member.t() | nil,
          Tester: Rpcpb.Tester.t() | nil
        }
  defstruct [:Operation, :Member, :Tester]

  field :Operation, 1, type: Rpcpb.Operation, enum: true
  field :Member, 2, type: Rpcpb.Member
  field :Tester, 3, type: Rpcpb.Tester
end

defmodule Rpcpb.SnapshotInfo do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          MemberName: String.t(),
          MemberClientURLs: [String.t()],
          SnapshotPath: String.t(),
          SnapshotFileSize: String.t(),
          SnapshotTotalSize: String.t(),
          SnapshotTotalKey: integer,
          SnapshotHash: integer,
          SnapshotRevision: integer,
          Took: String.t()
        }
  defstruct [
    :MemberName,
    :MemberClientURLs,
    :SnapshotPath,
    :SnapshotFileSize,
    :SnapshotTotalSize,
    :SnapshotTotalKey,
    :SnapshotHash,
    :SnapshotRevision,
    :Took
  ]

  field :MemberName, 1, type: :string
  field :MemberClientURLs, 2, repeated: true, type: :string
  field :SnapshotPath, 3, type: :string
  field :SnapshotFileSize, 4, type: :string
  field :SnapshotTotalSize, 5, type: :string
  field :SnapshotTotalKey, 6, type: :int64
  field :SnapshotHash, 7, type: :int64
  field :SnapshotRevision, 8, type: :int64
  field :Took, 9, type: :string
end

defmodule Rpcpb.Response do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          Success: boolean,
          Status: String.t(),
          Member: Rpcpb.Member.t() | nil,
          SnapshotInfo: Rpcpb.SnapshotInfo.t() | nil
        }
  defstruct [:Success, :Status, :Member, :SnapshotInfo]

  field :Success, 1, type: :bool
  field :Status, 2, type: :string
  field :Member, 3, type: Rpcpb.Member
  field :SnapshotInfo, 4, type: Rpcpb.SnapshotInfo
end

defmodule Rpcpb.Member do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          EtcdExec: String.t(),
          AgentAddr: String.t(),
          FailpointHTTPAddr: String.t(),
          BaseDir: String.t(),
          EtcdClientProxy: boolean,
          EtcdPeerProxy: boolean,
          EtcdClientEndpoint: String.t(),
          Etcd: Rpcpb.Etcd.t() | nil,
          EtcdOnSnapshotRestore: Rpcpb.Etcd.t() | nil,
          ClientCertData: String.t(),
          ClientCertPath: String.t(),
          ClientKeyData: String.t(),
          ClientKeyPath: String.t(),
          ClientTrustedCAData: String.t(),
          ClientTrustedCAPath: String.t(),
          PeerCertData: String.t(),
          PeerCertPath: String.t(),
          PeerKeyData: String.t(),
          PeerKeyPath: String.t(),
          PeerTrustedCAData: String.t(),
          PeerTrustedCAPath: String.t(),
          SnapshotPath: String.t(),
          SnapshotInfo: Rpcpb.SnapshotInfo.t() | nil
        }
  defstruct [
    :EtcdExec,
    :AgentAddr,
    :FailpointHTTPAddr,
    :BaseDir,
    :EtcdClientProxy,
    :EtcdPeerProxy,
    :EtcdClientEndpoint,
    :Etcd,
    :EtcdOnSnapshotRestore,
    :ClientCertData,
    :ClientCertPath,
    :ClientKeyData,
    :ClientKeyPath,
    :ClientTrustedCAData,
    :ClientTrustedCAPath,
    :PeerCertData,
    :PeerCertPath,
    :PeerKeyData,
    :PeerKeyPath,
    :PeerTrustedCAData,
    :PeerTrustedCAPath,
    :SnapshotPath,
    :SnapshotInfo
  ]

  field :EtcdExec, 1, type: :string
  field :AgentAddr, 11, type: :string
  field :FailpointHTTPAddr, 12, type: :string
  field :BaseDir, 101, type: :string
  field :EtcdClientProxy, 201, type: :bool
  field :EtcdPeerProxy, 202, type: :bool
  field :EtcdClientEndpoint, 301, type: :string
  field :Etcd, 302, type: Rpcpb.Etcd
  field :EtcdOnSnapshotRestore, 303, type: Rpcpb.Etcd
  field :ClientCertData, 401, type: :string
  field :ClientCertPath, 402, type: :string
  field :ClientKeyData, 403, type: :string
  field :ClientKeyPath, 404, type: :string
  field :ClientTrustedCAData, 405, type: :string
  field :ClientTrustedCAPath, 406, type: :string
  field :PeerCertData, 501, type: :string
  field :PeerCertPath, 502, type: :string
  field :PeerKeyData, 503, type: :string
  field :PeerKeyPath, 504, type: :string
  field :PeerTrustedCAData, 505, type: :string
  field :PeerTrustedCAPath, 506, type: :string
  field :SnapshotPath, 601, type: :string
  field :SnapshotInfo, 602, type: Rpcpb.SnapshotInfo
end

defmodule Rpcpb.Tester do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          DataDir: String.t(),
          Network: String.t(),
          Addr: String.t(),
          DelayLatencyMs: non_neg_integer,
          DelayLatencyMsRv: non_neg_integer,
          UpdatedDelayLatencyMs: non_neg_integer,
          RoundLimit: integer,
          ExitOnCaseFail: boolean,
          EnablePprof: boolean,
          CaseDelayMs: non_neg_integer,
          CaseShuffle: boolean,
          Cases: [String.t()],
          FailpointCommands: [String.t()],
          RunnerExecPath: String.t(),
          ExternalExecPath: String.t(),
          Stressers: [Rpcpb.Stresser.t()],
          Checkers: [String.t()],
          StressKeySize: integer,
          StressKeySizeLarge: integer,
          StressKeySuffixRange: integer,
          StressKeySuffixRangeTxn: integer,
          StressKeyTxnOps: integer,
          StressClients: integer,
          StressQPS: integer
        }
  defstruct [
    :DataDir,
    :Network,
    :Addr,
    :DelayLatencyMs,
    :DelayLatencyMsRv,
    :UpdatedDelayLatencyMs,
    :RoundLimit,
    :ExitOnCaseFail,
    :EnablePprof,
    :CaseDelayMs,
    :CaseShuffle,
    :Cases,
    :FailpointCommands,
    :RunnerExecPath,
    :ExternalExecPath,
    :Stressers,
    :Checkers,
    :StressKeySize,
    :StressKeySizeLarge,
    :StressKeySuffixRange,
    :StressKeySuffixRangeTxn,
    :StressKeyTxnOps,
    :StressClients,
    :StressQPS
  ]

  field :DataDir, 1, type: :string
  field :Network, 2, type: :string
  field :Addr, 3, type: :string
  field :DelayLatencyMs, 11, type: :uint32
  field :DelayLatencyMsRv, 12, type: :uint32
  field :UpdatedDelayLatencyMs, 13, type: :uint32
  field :RoundLimit, 21, type: :int32
  field :ExitOnCaseFail, 22, type: :bool
  field :EnablePprof, 23, type: :bool
  field :CaseDelayMs, 31, type: :uint32
  field :CaseShuffle, 32, type: :bool
  field :Cases, 33, repeated: true, type: :string
  field :FailpointCommands, 34, repeated: true, type: :string
  field :RunnerExecPath, 41, type: :string
  field :ExternalExecPath, 42, type: :string
  field :Stressers, 101, repeated: true, type: Rpcpb.Stresser
  field :Checkers, 102, repeated: true, type: :string
  field :StressKeySize, 201, type: :int32
  field :StressKeySizeLarge, 202, type: :int32
  field :StressKeySuffixRange, 203, type: :int32
  field :StressKeySuffixRangeTxn, 204, type: :int32
  field :StressKeyTxnOps, 205, type: :int32
  field :StressClients, 301, type: :int32
  field :StressQPS, 302, type: :int32
end

defmodule Rpcpb.Stresser do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          Type: String.t(),
          Weight: float | :infinity | :negative_infinity | :nan
        }
  defstruct [:Type, :Weight]

  field :Type, 1, type: :string
  field :Weight, 2, type: :double
end

defmodule Rpcpb.Etcd do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          Name: String.t(),
          DataDir: String.t(),
          WALDir: String.t(),
          HeartbeatIntervalMs: integer,
          ElectionTimeoutMs: integer,
          ListenClientURLs: [String.t()],
          AdvertiseClientURLs: [String.t()],
          ClientAutoTLS: boolean,
          ClientCertAuth: boolean,
          ClientCertFile: String.t(),
          ClientKeyFile: String.t(),
          ClientTrustedCAFile: String.t(),
          ListenPeerURLs: [String.t()],
          AdvertisePeerURLs: [String.t()],
          PeerAutoTLS: boolean,
          PeerClientCertAuth: boolean,
          PeerCertFile: String.t(),
          PeerKeyFile: String.t(),
          PeerTrustedCAFile: String.t(),
          InitialCluster: String.t(),
          InitialClusterState: String.t(),
          InitialClusterToken: String.t(),
          SnapshotCount: integer,
          QuotaBackendBytes: integer,
          PreVote: boolean,
          InitialCorruptCheck: boolean,
          Logger: String.t(),
          LogOutputs: [String.t()],
          LogLevel: String.t()
        }
  defstruct [
    :Name,
    :DataDir,
    :WALDir,
    :HeartbeatIntervalMs,
    :ElectionTimeoutMs,
    :ListenClientURLs,
    :AdvertiseClientURLs,
    :ClientAutoTLS,
    :ClientCertAuth,
    :ClientCertFile,
    :ClientKeyFile,
    :ClientTrustedCAFile,
    :ListenPeerURLs,
    :AdvertisePeerURLs,
    :PeerAutoTLS,
    :PeerClientCertAuth,
    :PeerCertFile,
    :PeerKeyFile,
    :PeerTrustedCAFile,
    :InitialCluster,
    :InitialClusterState,
    :InitialClusterToken,
    :SnapshotCount,
    :QuotaBackendBytes,
    :PreVote,
    :InitialCorruptCheck,
    :Logger,
    :LogOutputs,
    :LogLevel
  ]

  field :Name, 1, type: :string
  field :DataDir, 2, type: :string
  field :WALDir, 3, type: :string
  field :HeartbeatIntervalMs, 11, type: :int64
  field :ElectionTimeoutMs, 12, type: :int64
  field :ListenClientURLs, 21, repeated: true, type: :string
  field :AdvertiseClientURLs, 22, repeated: true, type: :string
  field :ClientAutoTLS, 23, type: :bool
  field :ClientCertAuth, 24, type: :bool
  field :ClientCertFile, 25, type: :string
  field :ClientKeyFile, 26, type: :string
  field :ClientTrustedCAFile, 27, type: :string
  field :ListenPeerURLs, 31, repeated: true, type: :string
  field :AdvertisePeerURLs, 32, repeated: true, type: :string
  field :PeerAutoTLS, 33, type: :bool
  field :PeerClientCertAuth, 34, type: :bool
  field :PeerCertFile, 35, type: :string
  field :PeerKeyFile, 36, type: :string
  field :PeerTrustedCAFile, 37, type: :string
  field :InitialCluster, 41, type: :string
  field :InitialClusterState, 42, type: :string
  field :InitialClusterToken, 43, type: :string
  field :SnapshotCount, 51, type: :int64
  field :QuotaBackendBytes, 52, type: :int64
  field :PreVote, 63, type: :bool
  field :InitialCorruptCheck, 64, type: :bool
  field :Logger, 71, type: :string
  field :LogOutputs, 72, repeated: true, type: :string
  field :LogLevel, 73, type: :string
end

defmodule Rpcpb.StresserType do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  field :KV_WRITE_SMALL, 0
  field :KV_WRITE_LARGE, 1
  field :KV_READ_ONE_KEY, 2
  field :KV_READ_RANGE, 3
  field :KV_DELETE_ONE_KEY, 4
  field :KV_DELETE_RANGE, 5
  field :KV_TXN_WRITE_DELETE, 6
  field :LEASE, 10
  field :ELECTION_RUNNER, 20
  field :WATCH_RUNNER, 31
  field :LOCK_RACER_RUNNER, 41
  field :LEASE_RUNNER, 51
end

defmodule Rpcpb.Checker do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  field :KV_HASH, 0
  field :LEASE_EXPIRE, 1
  field :RUNNER, 2
  field :NO_CHECK, 3
end

defmodule Rpcpb.Operation do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  field :NOT_STARTED, 0
  field :INITIAL_START_ETCD, 10
  field :RESTART_ETCD, 11
  field :SIGTERM_ETCD, 20
  field :SIGQUIT_ETCD_AND_REMOVE_DATA, 21
  field :SAVE_SNAPSHOT, 30
  field :RESTORE_RESTART_FROM_SNAPSHOT, 31
  field :RESTART_FROM_SNAPSHOT, 32
  field :SIGQUIT_ETCD_AND_ARCHIVE_DATA, 40
  field :SIGQUIT_ETCD_AND_REMOVE_DATA_AND_STOP_AGENT, 41
  field :BLACKHOLE_PEER_PORT_TX_RX, 100
  field :UNBLACKHOLE_PEER_PORT_TX_RX, 101
  field :DELAY_PEER_PORT_TX_RX, 200
  field :UNDELAY_PEER_PORT_TX_RX, 201
end

defmodule Rpcpb.Case do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  field :SIGTERM_ONE_FOLLOWER, 0
  field :SIGTERM_ONE_FOLLOWER_UNTIL_TRIGGER_SNAPSHOT, 1
  field :SIGTERM_LEADER, 2
  field :SIGTERM_LEADER_UNTIL_TRIGGER_SNAPSHOT, 3
  field :SIGTERM_QUORUM, 4
  field :SIGTERM_ALL, 5
  field :SIGQUIT_AND_REMOVE_ONE_FOLLOWER, 10
  field :SIGQUIT_AND_REMOVE_ONE_FOLLOWER_UNTIL_TRIGGER_SNAPSHOT, 11
  field :SIGQUIT_AND_REMOVE_LEADER, 12
  field :SIGQUIT_AND_REMOVE_LEADER_UNTIL_TRIGGER_SNAPSHOT, 13
  field :SIGQUIT_AND_REMOVE_QUORUM_AND_RESTORE_LEADER_SNAPSHOT_FROM_SCRATCH, 14
  field :BLACKHOLE_PEER_PORT_TX_RX_ONE_FOLLOWER, 100
  field :BLACKHOLE_PEER_PORT_TX_RX_ONE_FOLLOWER_UNTIL_TRIGGER_SNAPSHOT, 101
  field :BLACKHOLE_PEER_PORT_TX_RX_LEADER, 102
  field :BLACKHOLE_PEER_PORT_TX_RX_LEADER_UNTIL_TRIGGER_SNAPSHOT, 103
  field :BLACKHOLE_PEER_PORT_TX_RX_QUORUM, 104
  field :BLACKHOLE_PEER_PORT_TX_RX_ALL, 105
  field :DELAY_PEER_PORT_TX_RX_ONE_FOLLOWER, 200
  field :RANDOM_DELAY_PEER_PORT_TX_RX_ONE_FOLLOWER, 201
  field :DELAY_PEER_PORT_TX_RX_ONE_FOLLOWER_UNTIL_TRIGGER_SNAPSHOT, 202
  field :RANDOM_DELAY_PEER_PORT_TX_RX_ONE_FOLLOWER_UNTIL_TRIGGER_SNAPSHOT, 203
  field :DELAY_PEER_PORT_TX_RX_LEADER, 204
  field :RANDOM_DELAY_PEER_PORT_TX_RX_LEADER, 205
  field :DELAY_PEER_PORT_TX_RX_LEADER_UNTIL_TRIGGER_SNAPSHOT, 206
  field :RANDOM_DELAY_PEER_PORT_TX_RX_LEADER_UNTIL_TRIGGER_SNAPSHOT, 207
  field :DELAY_PEER_PORT_TX_RX_QUORUM, 208
  field :RANDOM_DELAY_PEER_PORT_TX_RX_QUORUM, 209
  field :DELAY_PEER_PORT_TX_RX_ALL, 210
  field :RANDOM_DELAY_PEER_PORT_TX_RX_ALL, 211
  field :NO_FAIL_WITH_STRESS, 300
  field :NO_FAIL_WITH_NO_STRESS_FOR_LIVENESS, 301
  field :FAILPOINTS, 400
  field :EXTERNAL, 500
end

defmodule Rpcpb.Transport.Service do
  @moduledoc false
  use GRPC.Service, name: "rpcpb.Transport"

  rpc :Transport, stream(Rpcpb.Request), stream(Rpcpb.Response)
end

defmodule Rpcpb.Transport.Stub do
  @moduledoc false
  use GRPC.Stub, service: Rpcpb.Transport.Service
end
