defmodule Mvccpb.Event.EventType do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  field :PUT, 0
  field :DELETE, 1
end

defmodule Mvccpb.KeyValue do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          key: binary,
          create_revision: integer,
          mod_revision: integer,
          version: integer,
          value: binary,
          lease: integer
        }
  defstruct [:key, :create_revision, :mod_revision, :version, :value, :lease]

  field :key, 1, type: :bytes
  field :create_revision, 2, type: :int64
  field :mod_revision, 3, type: :int64
  field :version, 4, type: :int64
  field :value, 5, type: :bytes
  field :lease, 6, type: :int64
end

defmodule Mvccpb.Event do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          type: atom | integer,
          kv: Mvccpb.KeyValue.t() | nil,
          prev_kv: Mvccpb.KeyValue.t() | nil
        }
  defstruct [:type, :kv, :prev_kv]

  field :type, 1, type: Mvccpb.Event.EventType, enum: true
  field :kv, 2, type: Mvccpb.KeyValue
  field :prev_kv, 3, type: Mvccpb.KeyValue
end
