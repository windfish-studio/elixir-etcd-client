defmodule Walpb.Record do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          type: integer,
          crc: non_neg_integer,
          data: binary
        }
  defstruct [:type, :crc, :data]

  field :type, 1, optional: true, type: :int64
  field :crc, 2, optional: true, type: :uint32
  field :data, 3, optional: true, type: :bytes
end

defmodule Walpb.Snapshot do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          index: non_neg_integer,
          term: non_neg_integer
        }
  defstruct [:index, :term]

  field :index, 1, optional: true, type: :uint64
  field :term, 2, optional: true, type: :uint64
end
