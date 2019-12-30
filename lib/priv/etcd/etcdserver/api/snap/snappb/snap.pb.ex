defmodule Snappb.Snapshot do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          crc: non_neg_integer,
          data: binary
        }
  defstruct [:crc, :data]

  field :crc, 1, optional: true, type: :uint32
  field :data, 2, optional: true, type: :bytes
end
