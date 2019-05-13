defmodule Etcdserverpb.Request do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          ID: non_neg_integer,
          Method: String.t(),
          Path: String.t(),
          Val: String.t(),
          Dir: boolean,
          PrevValue: String.t(),
          PrevIndex: non_neg_integer,
          PrevExist: boolean,
          Expiration: integer,
          Wait: boolean,
          Since: non_neg_integer,
          Recursive: boolean,
          Sorted: boolean,
          Quorum: boolean,
          Time: integer,
          Stream: boolean,
          Refresh: boolean
        }
  defstruct [
    :ID,
    :Method,
    :Path,
    :Val,
    :Dir,
    :PrevValue,
    :PrevIndex,
    :PrevExist,
    :Expiration,
    :Wait,
    :Since,
    :Recursive,
    :Sorted,
    :Quorum,
    :Time,
    :Stream,
    :Refresh
  ]

  field :ID, 1, optional: true, type: :uint64
  field :Method, 2, optional: true, type: :string
  field :Path, 3, optional: true, type: :string
  field :Val, 4, optional: true, type: :string
  field :Dir, 5, optional: true, type: :bool
  field :PrevValue, 6, optional: true, type: :string
  field :PrevIndex, 7, optional: true, type: :uint64
  field :PrevExist, 8, optional: true, type: :bool
  field :Expiration, 9, optional: true, type: :int64
  field :Wait, 10, optional: true, type: :bool
  field :Since, 11, optional: true, type: :uint64
  field :Recursive, 12, optional: true, type: :bool
  field :Sorted, 13, optional: true, type: :bool
  field :Quorum, 14, optional: true, type: :bool
  field :Time, 15, optional: true, type: :int64
  field :Stream, 16, optional: true, type: :bool
  field :Refresh, 17, optional: true, type: :bool
end

defmodule Etcdserverpb.Metadata do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          NodeID: non_neg_integer,
          ClusterID: non_neg_integer
        }
  defstruct [:NodeID, :ClusterID]

  field :NodeID, 1, optional: true, type: :uint64
  field :ClusterID, 2, optional: true, type: :uint64
end
