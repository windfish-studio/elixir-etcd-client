defmodule Leasepb.Lease do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          ID: integer,
          TTL: integer,
          RemainingTTL: integer
        }
  defstruct [:ID, :TTL, :RemainingTTL]

  field :ID, 1, type: :int64
  field :TTL, 2, type: :int64
  field :RemainingTTL, 3, type: :int64
end

defmodule Leasepb.LeaseInternalRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          LeaseTimeToLiveRequest: Etcdserverpb.LeaseTimeToLiveRequest.t() | nil
        }
  defstruct [:LeaseTimeToLiveRequest]

  field :LeaseTimeToLiveRequest, 1, type: Etcdserverpb.LeaseTimeToLiveRequest
end

defmodule Leasepb.LeaseInternalResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          LeaseTimeToLiveResponse: Etcdserverpb.LeaseTimeToLiveResponse.t() | nil
        }
  defstruct [:LeaseTimeToLiveResponse]

  field :LeaseTimeToLiveResponse, 1, type: Etcdserverpb.LeaseTimeToLiveResponse
end
