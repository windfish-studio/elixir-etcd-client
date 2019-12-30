defmodule V3lockpb.LockRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: binary,
          lease: integer
        }
  defstruct [:name, :lease]

  field :name, 1, type: :bytes
  field :lease, 2, type: :int64
end

defmodule V3lockpb.LockResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil,
          key: binary
        }
  defstruct [:header, :key]

  field :header, 1, type: Etcdserverpb.ResponseHeader
  field :key, 2, type: :bytes
end

defmodule V3lockpb.UnlockRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          key: binary
        }
  defstruct [:key]

  field :key, 1, type: :bytes
end

defmodule V3lockpb.UnlockResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil
        }
  defstruct [:header]

  field :header, 1, type: Etcdserverpb.ResponseHeader
end

defmodule V3lockpb.Lock.Service do
  @moduledoc false
  use GRPC.Service, name: "v3lockpb.Lock"

  rpc :Lock, V3lockpb.LockRequest, V3lockpb.LockResponse
  rpc :Unlock, V3lockpb.UnlockRequest, V3lockpb.UnlockResponse
end

defmodule V3lockpb.Lock.Stub do
  @moduledoc false
  use GRPC.Stub, service: V3lockpb.Lock.Service
end
