defmodule Etcdserverpb.ResponseHeader do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          cluster_id: non_neg_integer,
          member_id: non_neg_integer,
          revision: integer,
          raft_term: non_neg_integer
        }
  defstruct [:cluster_id, :member_id, :revision, :raft_term]

  field :cluster_id, 1, type: :uint64
  field :member_id, 2, type: :uint64
  field :revision, 3, type: :int64
  field :raft_term, 4, type: :uint64
end

defmodule Etcdserverpb.RangeRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          key: binary,
          range_end: binary,
          limit: integer,
          revision: integer,
          sort_order: atom | integer,
          sort_target: atom | integer,
          serializable: boolean,
          keys_only: boolean,
          count_only: boolean,
          min_mod_revision: integer,
          max_mod_revision: integer,
          min_create_revision: integer,
          max_create_revision: integer
        }
  defstruct [
    :key,
    :range_end,
    :limit,
    :revision,
    :sort_order,
    :sort_target,
    :serializable,
    :keys_only,
    :count_only,
    :min_mod_revision,
    :max_mod_revision,
    :min_create_revision,
    :max_create_revision
  ]

  field :key, 1, type: :bytes
  field :range_end, 2, type: :bytes
  field :limit, 3, type: :int64
  field :revision, 4, type: :int64
  field :sort_order, 5, type: Etcdserverpb.RangeRequest.SortOrder, enum: true
  field :sort_target, 6, type: Etcdserverpb.RangeRequest.SortTarget, enum: true
  field :serializable, 7, type: :bool
  field :keys_only, 8, type: :bool
  field :count_only, 9, type: :bool
  field :min_mod_revision, 10, type: :int64
  field :max_mod_revision, 11, type: :int64
  field :min_create_revision, 12, type: :int64
  field :max_create_revision, 13, type: :int64
end

defmodule Etcdserverpb.RangeRequest.SortOrder do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  field :NONE, 0
  field :ASCEND, 1
  field :DESCEND, 2
end

defmodule Etcdserverpb.RangeRequest.SortTarget do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  field :KEY, 0
  field :VERSION, 1
  field :CREATE, 2
  field :MOD, 3
  field :VALUE, 4
end

defmodule Etcdserverpb.RangeResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil,
          kvs: [Mvccpb.KeyValue.t()],
          more: boolean,
          count: integer
        }
  defstruct [:header, :kvs, :more, :count]

  field :header, 1, type: Etcdserverpb.ResponseHeader
  field :kvs, 2, repeated: true, type: Mvccpb.KeyValue
  field :more, 3, type: :bool
  field :count, 4, type: :int64
end

defmodule Etcdserverpb.PutRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          key: binary,
          value: binary,
          lease: integer,
          prev_kv: boolean,
          ignore_value: boolean,
          ignore_lease: boolean
        }
  defstruct [:key, :value, :lease, :prev_kv, :ignore_value, :ignore_lease]

  field :key, 1, type: :bytes
  field :value, 2, type: :bytes
  field :lease, 3, type: :int64
  field :prev_kv, 4, type: :bool
  field :ignore_value, 5, type: :bool
  field :ignore_lease, 6, type: :bool
end

defmodule Etcdserverpb.PutResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil,
          prev_kv: Mvccpb.KeyValue.t() | nil
        }
  defstruct [:header, :prev_kv]

  field :header, 1, type: Etcdserverpb.ResponseHeader
  field :prev_kv, 2, type: Mvccpb.KeyValue
end

defmodule Etcdserverpb.DeleteRangeRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          key: binary,
          range_end: binary,
          prev_kv: boolean
        }
  defstruct [:key, :range_end, :prev_kv]

  field :key, 1, type: :bytes
  field :range_end, 2, type: :bytes
  field :prev_kv, 3, type: :bool
end

defmodule Etcdserverpb.DeleteRangeResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil,
          deleted: integer,
          prev_kvs: [Mvccpb.KeyValue.t()]
        }
  defstruct [:header, :deleted, :prev_kvs]

  field :header, 1, type: Etcdserverpb.ResponseHeader
  field :deleted, 2, type: :int64
  field :prev_kvs, 3, repeated: true, type: Mvccpb.KeyValue
end

defmodule Etcdserverpb.RequestOp do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          request: {atom, any}
        }
  defstruct [:request]

  oneof :request, 0
  field :request_range, 1, type: Etcdserverpb.RangeRequest, oneof: 0
  field :request_put, 2, type: Etcdserverpb.PutRequest, oneof: 0
  field :request_delete_range, 3, type: Etcdserverpb.DeleteRangeRequest, oneof: 0
  field :request_txn, 4, type: Etcdserverpb.TxnRequest, oneof: 0
end

defmodule Etcdserverpb.ResponseOp do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          response: {atom, any}
        }
  defstruct [:response]

  oneof :response, 0
  field :response_range, 1, type: Etcdserverpb.RangeResponse, oneof: 0
  field :response_put, 2, type: Etcdserverpb.PutResponse, oneof: 0
  field :response_delete_range, 3, type: Etcdserverpb.DeleteRangeResponse, oneof: 0
  field :response_txn, 4, type: Etcdserverpb.TxnResponse, oneof: 0
end

defmodule Etcdserverpb.Compare do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          target_union: {atom, any},
          result: atom | integer,
          target: atom | integer,
          key: binary,
          range_end: binary
        }
  defstruct [:target_union, :result, :target, :key, :range_end]

  oneof :target_union, 0
  field :result, 1, type: Etcdserverpb.Compare.CompareResult, enum: true
  field :target, 2, type: Etcdserverpb.Compare.CompareTarget, enum: true
  field :key, 3, type: :bytes
  field :version, 4, type: :int64, oneof: 0
  field :create_revision, 5, type: :int64, oneof: 0
  field :mod_revision, 6, type: :int64, oneof: 0
  field :value, 7, type: :bytes, oneof: 0
  field :lease, 8, type: :int64, oneof: 0
  field :range_end, 64, type: :bytes
end

defmodule Etcdserverpb.Compare.CompareResult do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  field :EQUAL, 0
  field :GREATER, 1
  field :LESS, 2
  field :NOT_EQUAL, 3
end

defmodule Etcdserverpb.Compare.CompareTarget do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  field :VERSION, 0
  field :CREATE, 1
  field :MOD, 2
  field :VALUE, 3
  field :LEASE, 4
end

defmodule Etcdserverpb.TxnRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          compare: [Etcdserverpb.Compare.t()],
          success: [Etcdserverpb.RequestOp.t()],
          failure: [Etcdserverpb.RequestOp.t()]
        }
  defstruct [:compare, :success, :failure]

  field :compare, 1, repeated: true, type: Etcdserverpb.Compare
  field :success, 2, repeated: true, type: Etcdserverpb.RequestOp
  field :failure, 3, repeated: true, type: Etcdserverpb.RequestOp
end

defmodule Etcdserverpb.TxnResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil,
          succeeded: boolean,
          responses: [Etcdserverpb.ResponseOp.t()]
        }
  defstruct [:header, :succeeded, :responses]

  field :header, 1, type: Etcdserverpb.ResponseHeader
  field :succeeded, 2, type: :bool
  field :responses, 3, repeated: true, type: Etcdserverpb.ResponseOp
end

defmodule Etcdserverpb.CompactionRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          revision: integer,
          physical: boolean
        }
  defstruct [:revision, :physical]

  field :revision, 1, type: :int64
  field :physical, 2, type: :bool
end

defmodule Etcdserverpb.CompactionResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil
        }
  defstruct [:header]

  field :header, 1, type: Etcdserverpb.ResponseHeader
end

defmodule Etcdserverpb.HashRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{}
  defstruct []
end

defmodule Etcdserverpb.HashKVRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          revision: integer
        }
  defstruct [:revision]

  field :revision, 1, type: :int64
end

defmodule Etcdserverpb.HashKVResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil,
          hash: non_neg_integer,
          compact_revision: integer
        }
  defstruct [:header, :hash, :compact_revision]

  field :header, 1, type: Etcdserverpb.ResponseHeader
  field :hash, 2, type: :uint32
  field :compact_revision, 3, type: :int64
end

defmodule Etcdserverpb.HashResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil,
          hash: non_neg_integer
        }
  defstruct [:header, :hash]

  field :header, 1, type: Etcdserverpb.ResponseHeader
  field :hash, 2, type: :uint32
end

defmodule Etcdserverpb.SnapshotRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{}
  defstruct []
end

defmodule Etcdserverpb.SnapshotResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil,
          remaining_bytes: non_neg_integer,
          blob: binary
        }
  defstruct [:header, :remaining_bytes, :blob]

  field :header, 1, type: Etcdserverpb.ResponseHeader
  field :remaining_bytes, 2, type: :uint64
  field :blob, 3, type: :bytes
end

defmodule Etcdserverpb.WatchRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          request_union: {atom, any}
        }
  defstruct [:request_union]

  oneof :request_union, 0
  field :create_request, 1, type: Etcdserverpb.WatchCreateRequest, oneof: 0
  field :cancel_request, 2, type: Etcdserverpb.WatchCancelRequest, oneof: 0
  field :progress_request, 3, type: Etcdserverpb.WatchProgressRequest, oneof: 0
end

defmodule Etcdserverpb.WatchCreateRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          key: binary,
          range_end: binary,
          start_revision: integer,
          progress_notify: boolean,
          filters: [atom | integer],
          prev_kv: boolean,
          watch_id: integer,
          fragment: boolean
        }
  defstruct [
    :key,
    :range_end,
    :start_revision,
    :progress_notify,
    :filters,
    :prev_kv,
    :watch_id,
    :fragment
  ]

  field :key, 1, type: :bytes
  field :range_end, 2, type: :bytes
  field :start_revision, 3, type: :int64
  field :progress_notify, 4, type: :bool
  field :filters, 5, repeated: true, type: Etcdserverpb.WatchCreateRequest.FilterType, enum: true
  field :prev_kv, 6, type: :bool
  field :watch_id, 7, type: :int64
  field :fragment, 8, type: :bool
end

defmodule Etcdserverpb.WatchCreateRequest.FilterType do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  field :NOPUT, 0
  field :NODELETE, 1
end

defmodule Etcdserverpb.WatchCancelRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          watch_id: integer
        }
  defstruct [:watch_id]

  field :watch_id, 1, type: :int64
end

defmodule Etcdserverpb.WatchProgressRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{}
  defstruct []
end

defmodule Etcdserverpb.WatchResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil,
          watch_id: integer,
          created: boolean,
          canceled: boolean,
          compact_revision: integer,
          cancel_reason: String.t(),
          fragment: boolean,
          events: [Mvccpb.Event.t()]
        }
  defstruct [
    :header,
    :watch_id,
    :created,
    :canceled,
    :compact_revision,
    :cancel_reason,
    :fragment,
    :events
  ]

  field :header, 1, type: Etcdserverpb.ResponseHeader
  field :watch_id, 2, type: :int64
  field :created, 3, type: :bool
  field :canceled, 4, type: :bool
  field :compact_revision, 5, type: :int64
  field :cancel_reason, 6, type: :string
  field :fragment, 7, type: :bool
  field :events, 11, repeated: true, type: Mvccpb.Event
end

defmodule Etcdserverpb.LeaseGrantRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          TTL: integer,
          ID: integer
        }
  defstruct [:TTL, :ID]

  field :TTL, 1, type: :int64
  field :ID, 2, type: :int64
end

defmodule Etcdserverpb.LeaseGrantResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil,
          ID: integer,
          TTL: integer,
          error: String.t()
        }
  defstruct [:header, :ID, :TTL, :error]

  field :header, 1, type: Etcdserverpb.ResponseHeader
  field :ID, 2, type: :int64
  field :TTL, 3, type: :int64
  field :error, 4, type: :string
end

defmodule Etcdserverpb.LeaseRevokeRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          ID: integer
        }
  defstruct [:ID]

  field :ID, 1, type: :int64
end

defmodule Etcdserverpb.LeaseRevokeResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil
        }
  defstruct [:header]

  field :header, 1, type: Etcdserverpb.ResponseHeader
end

defmodule Etcdserverpb.LeaseCheckpoint do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          ID: integer,
          remaining_TTL: integer
        }
  defstruct [:ID, :remaining_TTL]

  field :ID, 1, type: :int64
  field :remaining_TTL, 2, type: :int64
end

defmodule Etcdserverpb.LeaseCheckpointRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          checkpoints: [Etcdserverpb.LeaseCheckpoint.t()]
        }
  defstruct [:checkpoints]

  field :checkpoints, 1, repeated: true, type: Etcdserverpb.LeaseCheckpoint
end

defmodule Etcdserverpb.LeaseCheckpointResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil
        }
  defstruct [:header]

  field :header, 1, type: Etcdserverpb.ResponseHeader
end

defmodule Etcdserverpb.LeaseKeepAliveRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          ID: integer
        }
  defstruct [:ID]

  field :ID, 1, type: :int64
end

defmodule Etcdserverpb.LeaseKeepAliveResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil,
          ID: integer,
          TTL: integer
        }
  defstruct [:header, :ID, :TTL]

  field :header, 1, type: Etcdserverpb.ResponseHeader
  field :ID, 2, type: :int64
  field :TTL, 3, type: :int64
end

defmodule Etcdserverpb.LeaseTimeToLiveRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          ID: integer,
          keys: boolean
        }
  defstruct [:ID, :keys]

  field :ID, 1, type: :int64
  field :keys, 2, type: :bool
end

defmodule Etcdserverpb.LeaseTimeToLiveResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil,
          ID: integer,
          TTL: integer,
          grantedTTL: integer,
          keys: [binary]
        }
  defstruct [:header, :ID, :TTL, :grantedTTL, :keys]

  field :header, 1, type: Etcdserverpb.ResponseHeader
  field :ID, 2, type: :int64
  field :TTL, 3, type: :int64
  field :grantedTTL, 4, type: :int64
  field :keys, 5, repeated: true, type: :bytes
end

defmodule Etcdserverpb.LeaseLeasesRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{}
  defstruct []
end

defmodule Etcdserverpb.LeaseStatus do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          ID: integer
        }
  defstruct [:ID]

  field :ID, 1, type: :int64
end

defmodule Etcdserverpb.LeaseLeasesResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil,
          leases: [Etcdserverpb.LeaseStatus.t()]
        }
  defstruct [:header, :leases]

  field :header, 1, type: Etcdserverpb.ResponseHeader
  field :leases, 2, repeated: true, type: Etcdserverpb.LeaseStatus
end

defmodule Etcdserverpb.Member do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          ID: non_neg_integer,
          name: String.t(),
          peerURLs: [String.t()],
          clientURLs: [String.t()],
          isLearner: boolean
        }
  defstruct [:ID, :name, :peerURLs, :clientURLs, :isLearner]

  field :ID, 1, type: :uint64
  field :name, 2, type: :string
  field :peerURLs, 3, repeated: true, type: :string
  field :clientURLs, 4, repeated: true, type: :string
  field :isLearner, 5, type: :bool
end

defmodule Etcdserverpb.MemberAddRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          peerURLs: [String.t()],
          isLearner: boolean
        }
  defstruct [:peerURLs, :isLearner]

  field :peerURLs, 1, repeated: true, type: :string
  field :isLearner, 2, type: :bool
end

defmodule Etcdserverpb.MemberAddResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil,
          member: Etcdserverpb.Member.t() | nil,
          members: [Etcdserverpb.Member.t()]
        }
  defstruct [:header, :member, :members]

  field :header, 1, type: Etcdserverpb.ResponseHeader
  field :member, 2, type: Etcdserverpb.Member
  field :members, 3, repeated: true, type: Etcdserverpb.Member
end

defmodule Etcdserverpb.MemberRemoveRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          ID: non_neg_integer
        }
  defstruct [:ID]

  field :ID, 1, type: :uint64
end

defmodule Etcdserverpb.MemberRemoveResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil,
          members: [Etcdserverpb.Member.t()]
        }
  defstruct [:header, :members]

  field :header, 1, type: Etcdserverpb.ResponseHeader
  field :members, 2, repeated: true, type: Etcdserverpb.Member
end

defmodule Etcdserverpb.MemberUpdateRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          ID: non_neg_integer,
          peerURLs: [String.t()]
        }
  defstruct [:ID, :peerURLs]

  field :ID, 1, type: :uint64
  field :peerURLs, 2, repeated: true, type: :string
end

defmodule Etcdserverpb.MemberUpdateResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil,
          members: [Etcdserverpb.Member.t()]
        }
  defstruct [:header, :members]

  field :header, 1, type: Etcdserverpb.ResponseHeader
  field :members, 2, repeated: true, type: Etcdserverpb.Member
end

defmodule Etcdserverpb.MemberListRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{}
  defstruct []
end

defmodule Etcdserverpb.MemberListResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil,
          members: [Etcdserverpb.Member.t()]
        }
  defstruct [:header, :members]

  field :header, 1, type: Etcdserverpb.ResponseHeader
  field :members, 2, repeated: true, type: Etcdserverpb.Member
end

defmodule Etcdserverpb.MemberPromoteRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          ID: non_neg_integer
        }
  defstruct [:ID]

  field :ID, 1, type: :uint64
end

defmodule Etcdserverpb.MemberPromoteResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil,
          members: [Etcdserverpb.Member.t()]
        }
  defstruct [:header, :members]

  field :header, 1, type: Etcdserverpb.ResponseHeader
  field :members, 2, repeated: true, type: Etcdserverpb.Member
end

defmodule Etcdserverpb.DefragmentRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{}
  defstruct []
end

defmodule Etcdserverpb.DefragmentResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil
        }
  defstruct [:header]

  field :header, 1, type: Etcdserverpb.ResponseHeader
end

defmodule Etcdserverpb.MoveLeaderRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          targetID: non_neg_integer
        }
  defstruct [:targetID]

  field :targetID, 1, type: :uint64
end

defmodule Etcdserverpb.MoveLeaderResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil
        }
  defstruct [:header]

  field :header, 1, type: Etcdserverpb.ResponseHeader
end

defmodule Etcdserverpb.AlarmRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          action: atom | integer,
          memberID: non_neg_integer,
          alarm: atom | integer
        }
  defstruct [:action, :memberID, :alarm]

  field :action, 1, type: Etcdserverpb.AlarmRequest.AlarmAction, enum: true
  field :memberID, 2, type: :uint64
  field :alarm, 3, type: Etcdserverpb.AlarmType, enum: true
end

defmodule Etcdserverpb.AlarmRequest.AlarmAction do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  field :GET, 0
  field :ACTIVATE, 1
  field :DEACTIVATE, 2
end

defmodule Etcdserverpb.AlarmMember do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          memberID: non_neg_integer,
          alarm: atom | integer
        }
  defstruct [:memberID, :alarm]

  field :memberID, 1, type: :uint64
  field :alarm, 2, type: Etcdserverpb.AlarmType, enum: true
end

defmodule Etcdserverpb.AlarmResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil,
          alarms: [Etcdserverpb.AlarmMember.t()]
        }
  defstruct [:header, :alarms]

  field :header, 1, type: Etcdserverpb.ResponseHeader
  field :alarms, 2, repeated: true, type: Etcdserverpb.AlarmMember
end

defmodule Etcdserverpb.StatusRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{}
  defstruct []
end

defmodule Etcdserverpb.StatusResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil,
          version: String.t(),
          dbSize: integer,
          leader: non_neg_integer,
          raftIndex: non_neg_integer,
          raftTerm: non_neg_integer,
          raftAppliedIndex: non_neg_integer,
          errors: [String.t()],
          dbSizeInUse: integer,
          isLearner: boolean
        }
  defstruct [
    :header,
    :version,
    :dbSize,
    :leader,
    :raftIndex,
    :raftTerm,
    :raftAppliedIndex,
    :errors,
    :dbSizeInUse,
    :isLearner
  ]

  field :header, 1, type: Etcdserverpb.ResponseHeader
  field :version, 2, type: :string
  field :dbSize, 3, type: :int64
  field :leader, 4, type: :uint64
  field :raftIndex, 5, type: :uint64
  field :raftTerm, 6, type: :uint64
  field :raftAppliedIndex, 7, type: :uint64
  field :errors, 8, repeated: true, type: :string
  field :dbSizeInUse, 9, type: :int64
  field :isLearner, 10, type: :bool
end

defmodule Etcdserverpb.AuthEnableRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{}
  defstruct []
end

defmodule Etcdserverpb.AuthDisableRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{}
  defstruct []
end

defmodule Etcdserverpb.AuthenticateRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: String.t(),
          password: String.t()
        }
  defstruct [:name, :password]

  field :name, 1, type: :string
  field :password, 2, type: :string
end

defmodule Etcdserverpb.AuthUserAddRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: String.t(),
          password: String.t(),
          options: Authpb.UserAddOptions.t() | nil
        }
  defstruct [:name, :password, :options]

  field :name, 1, type: :string
  field :password, 2, type: :string
  field :options, 3, type: Authpb.UserAddOptions
end

defmodule Etcdserverpb.AuthUserGetRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: String.t()
        }
  defstruct [:name]

  field :name, 1, type: :string
end

defmodule Etcdserverpb.AuthUserDeleteRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: String.t()
        }
  defstruct [:name]

  field :name, 1, type: :string
end

defmodule Etcdserverpb.AuthUserChangePasswordRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: String.t(),
          password: String.t()
        }
  defstruct [:name, :password]

  field :name, 1, type: :string
  field :password, 2, type: :string
end

defmodule Etcdserverpb.AuthUserGrantRoleRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          user: String.t(),
          role: String.t()
        }
  defstruct [:user, :role]

  field :user, 1, type: :string
  field :role, 2, type: :string
end

defmodule Etcdserverpb.AuthUserRevokeRoleRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: String.t(),
          role: String.t()
        }
  defstruct [:name, :role]

  field :name, 1, type: :string
  field :role, 2, type: :string
end

defmodule Etcdserverpb.AuthRoleAddRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: String.t()
        }
  defstruct [:name]

  field :name, 1, type: :string
end

defmodule Etcdserverpb.AuthRoleGetRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          role: String.t()
        }
  defstruct [:role]

  field :role, 1, type: :string
end

defmodule Etcdserverpb.AuthUserListRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{}
  defstruct []
end

defmodule Etcdserverpb.AuthRoleListRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{}
  defstruct []
end

defmodule Etcdserverpb.AuthRoleDeleteRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          role: String.t()
        }
  defstruct [:role]

  field :role, 1, type: :string
end

defmodule Etcdserverpb.AuthRoleGrantPermissionRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: String.t(),
          perm: Authpb.Permission.t() | nil
        }
  defstruct [:name, :perm]

  field :name, 1, type: :string
  field :perm, 2, type: Authpb.Permission
end

defmodule Etcdserverpb.AuthRoleRevokePermissionRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          role: String.t(),
          key: binary,
          range_end: binary
        }
  defstruct [:role, :key, :range_end]

  field :role, 1, type: :string
  field :key, 2, type: :bytes
  field :range_end, 3, type: :bytes
end

defmodule Etcdserverpb.AuthEnableResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil
        }
  defstruct [:header]

  field :header, 1, type: Etcdserverpb.ResponseHeader
end

defmodule Etcdserverpb.AuthDisableResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil
        }
  defstruct [:header]

  field :header, 1, type: Etcdserverpb.ResponseHeader
end

defmodule Etcdserverpb.AuthenticateResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil,
          token: String.t()
        }
  defstruct [:header, :token]

  field :header, 1, type: Etcdserverpb.ResponseHeader
  field :token, 2, type: :string
end

defmodule Etcdserverpb.AuthUserAddResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil
        }
  defstruct [:header]

  field :header, 1, type: Etcdserverpb.ResponseHeader
end

defmodule Etcdserverpb.AuthUserGetResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil,
          roles: [String.t()]
        }
  defstruct [:header, :roles]

  field :header, 1, type: Etcdserverpb.ResponseHeader
  field :roles, 2, repeated: true, type: :string
end

defmodule Etcdserverpb.AuthUserDeleteResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil
        }
  defstruct [:header]

  field :header, 1, type: Etcdserverpb.ResponseHeader
end

defmodule Etcdserverpb.AuthUserChangePasswordResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil
        }
  defstruct [:header]

  field :header, 1, type: Etcdserverpb.ResponseHeader
end

defmodule Etcdserverpb.AuthUserGrantRoleResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil
        }
  defstruct [:header]

  field :header, 1, type: Etcdserverpb.ResponseHeader
end

defmodule Etcdserverpb.AuthUserRevokeRoleResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil
        }
  defstruct [:header]

  field :header, 1, type: Etcdserverpb.ResponseHeader
end

defmodule Etcdserverpb.AuthRoleAddResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil
        }
  defstruct [:header]

  field :header, 1, type: Etcdserverpb.ResponseHeader
end

defmodule Etcdserverpb.AuthRoleGetResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil,
          perm: [Authpb.Permission.t()]
        }
  defstruct [:header, :perm]

  field :header, 1, type: Etcdserverpb.ResponseHeader
  field :perm, 2, repeated: true, type: Authpb.Permission
end

defmodule Etcdserverpb.AuthRoleListResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil,
          roles: [String.t()]
        }
  defstruct [:header, :roles]

  field :header, 1, type: Etcdserverpb.ResponseHeader
  field :roles, 2, repeated: true, type: :string
end

defmodule Etcdserverpb.AuthUserListResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil,
          users: [String.t()]
        }
  defstruct [:header, :users]

  field :header, 1, type: Etcdserverpb.ResponseHeader
  field :users, 2, repeated: true, type: :string
end

defmodule Etcdserverpb.AuthRoleDeleteResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil
        }
  defstruct [:header]

  field :header, 1, type: Etcdserverpb.ResponseHeader
end

defmodule Etcdserverpb.AuthRoleGrantPermissionResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil
        }
  defstruct [:header]

  field :header, 1, type: Etcdserverpb.ResponseHeader
end

defmodule Etcdserverpb.AuthRoleRevokePermissionResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil
        }
  defstruct [:header]

  field :header, 1, type: Etcdserverpb.ResponseHeader
end

defmodule Etcdserverpb.AlarmType do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  field :NONE, 0
  field :NOSPACE, 1
  field :CORRUPT, 2
end

defmodule Etcdserverpb.KV.Service do
  @moduledoc false
  use GRPC.Service, name: "etcdserverpb.KV"

  rpc :Range, Etcdserverpb.RangeRequest, Etcdserverpb.RangeResponse
  rpc :Put, Etcdserverpb.PutRequest, Etcdserverpb.PutResponse
  rpc :DeleteRange, Etcdserverpb.DeleteRangeRequest, Etcdserverpb.DeleteRangeResponse
  rpc :Txn, Etcdserverpb.TxnRequest, Etcdserverpb.TxnResponse
  rpc :Compact, Etcdserverpb.CompactionRequest, Etcdserverpb.CompactionResponse
end

defmodule Etcdserverpb.KV.Stub do
  @moduledoc false
  use GRPC.Stub, service: Etcdserverpb.KV.Service
end

defmodule Etcdserverpb.Watch.Service do
  @moduledoc false
  use GRPC.Service, name: "etcdserverpb.Watch"

  rpc :Watch, stream(Etcdserverpb.WatchRequest), stream(Etcdserverpb.WatchResponse)
end

defmodule Etcdserverpb.Watch.Stub do
  @moduledoc false
  use GRPC.Stub, service: Etcdserverpb.Watch.Service
end

defmodule Etcdserverpb.Lease.Service do
  @moduledoc false
  use GRPC.Service, name: "etcdserverpb.Lease"

  rpc :LeaseGrant, Etcdserverpb.LeaseGrantRequest, Etcdserverpb.LeaseGrantResponse
  rpc :LeaseRevoke, Etcdserverpb.LeaseRevokeRequest, Etcdserverpb.LeaseRevokeResponse

  rpc :LeaseKeepAlive,
      stream(Etcdserverpb.LeaseKeepAliveRequest),
      stream(Etcdserverpb.LeaseKeepAliveResponse)

  rpc :LeaseTimeToLive, Etcdserverpb.LeaseTimeToLiveRequest, Etcdserverpb.LeaseTimeToLiveResponse
  rpc :LeaseLeases, Etcdserverpb.LeaseLeasesRequest, Etcdserverpb.LeaseLeasesResponse
end

defmodule Etcdserverpb.Lease.Stub do
  @moduledoc false
  use GRPC.Stub, service: Etcdserverpb.Lease.Service
end

defmodule Etcdserverpb.Cluster.Service do
  @moduledoc false
  use GRPC.Service, name: "etcdserverpb.Cluster"

  rpc :MemberAdd, Etcdserverpb.MemberAddRequest, Etcdserverpb.MemberAddResponse
  rpc :MemberRemove, Etcdserverpb.MemberRemoveRequest, Etcdserverpb.MemberRemoveResponse
  rpc :MemberUpdate, Etcdserverpb.MemberUpdateRequest, Etcdserverpb.MemberUpdateResponse
  rpc :MemberList, Etcdserverpb.MemberListRequest, Etcdserverpb.MemberListResponse
  rpc :MemberPromote, Etcdserverpb.MemberPromoteRequest, Etcdserverpb.MemberPromoteResponse
end

defmodule Etcdserverpb.Cluster.Stub do
  @moduledoc false
  use GRPC.Stub, service: Etcdserverpb.Cluster.Service
end

defmodule Etcdserverpb.Maintenance.Service do
  @moduledoc false
  use GRPC.Service, name: "etcdserverpb.Maintenance"

  rpc :Alarm, Etcdserverpb.AlarmRequest, Etcdserverpb.AlarmResponse
  rpc :Status, Etcdserverpb.StatusRequest, Etcdserverpb.StatusResponse
  rpc :Defragment, Etcdserverpb.DefragmentRequest, Etcdserverpb.DefragmentResponse
  rpc :Hash, Etcdserverpb.HashRequest, Etcdserverpb.HashResponse
  rpc :HashKV, Etcdserverpb.HashKVRequest, Etcdserverpb.HashKVResponse
  rpc :Snapshot, Etcdserverpb.SnapshotRequest, stream(Etcdserverpb.SnapshotResponse)
  rpc :MoveLeader, Etcdserverpb.MoveLeaderRequest, Etcdserverpb.MoveLeaderResponse
end

defmodule Etcdserverpb.Maintenance.Stub do
  @moduledoc false
  use GRPC.Stub, service: Etcdserverpb.Maintenance.Service
end

defmodule Etcdserverpb.Auth.Service do
  @moduledoc false
  use GRPC.Service, name: "etcdserverpb.Auth"

  rpc :AuthEnable, Etcdserverpb.AuthEnableRequest, Etcdserverpb.AuthEnableResponse
  rpc :AuthDisable, Etcdserverpb.AuthDisableRequest, Etcdserverpb.AuthDisableResponse
  rpc :Authenticate, Etcdserverpb.AuthenticateRequest, Etcdserverpb.AuthenticateResponse
  rpc :UserAdd, Etcdserverpb.AuthUserAddRequest, Etcdserverpb.AuthUserAddResponse
  rpc :UserGet, Etcdserverpb.AuthUserGetRequest, Etcdserverpb.AuthUserGetResponse
  rpc :UserList, Etcdserverpb.AuthUserListRequest, Etcdserverpb.AuthUserListResponse
  rpc :UserDelete, Etcdserverpb.AuthUserDeleteRequest, Etcdserverpb.AuthUserDeleteResponse

  rpc :UserChangePassword,
      Etcdserverpb.AuthUserChangePasswordRequest,
      Etcdserverpb.AuthUserChangePasswordResponse

  rpc :UserGrantRole,
      Etcdserverpb.AuthUserGrantRoleRequest,
      Etcdserverpb.AuthUserGrantRoleResponse

  rpc :UserRevokeRole,
      Etcdserverpb.AuthUserRevokeRoleRequest,
      Etcdserverpb.AuthUserRevokeRoleResponse

  rpc :RoleAdd, Etcdserverpb.AuthRoleAddRequest, Etcdserverpb.AuthRoleAddResponse
  rpc :RoleGet, Etcdserverpb.AuthRoleGetRequest, Etcdserverpb.AuthRoleGetResponse
  rpc :RoleList, Etcdserverpb.AuthRoleListRequest, Etcdserverpb.AuthRoleListResponse
  rpc :RoleDelete, Etcdserverpb.AuthRoleDeleteRequest, Etcdserverpb.AuthRoleDeleteResponse

  rpc :RoleGrantPermission,
      Etcdserverpb.AuthRoleGrantPermissionRequest,
      Etcdserverpb.AuthRoleGrantPermissionResponse

  rpc :RoleRevokePermission,
      Etcdserverpb.AuthRoleRevokePermissionRequest,
      Etcdserverpb.AuthRoleRevokePermissionResponse
end

defmodule Etcdserverpb.Auth.Stub do
  @moduledoc false
  use GRPC.Stub, service: Etcdserverpb.Auth.Service
end
