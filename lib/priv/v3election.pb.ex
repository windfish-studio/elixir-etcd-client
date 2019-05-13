defmodule V3electionpb.CampaignRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: binary,
          lease: integer,
          value: binary
        }
  defstruct [:name, :lease, :value]

  field :name, 1, type: :bytes
  field :lease, 2, type: :int64
  field :value, 3, type: :bytes
end

defmodule V3electionpb.CampaignResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil,
          leader: V3electionpb.LeaderKey.t() | nil
        }
  defstruct [:header, :leader]

  field :header, 1, type: Etcdserverpb.ResponseHeader
  field :leader, 2, type: V3electionpb.LeaderKey
end

defmodule V3electionpb.LeaderKey do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: binary,
          key: binary,
          rev: integer,
          lease: integer
        }
  defstruct [:name, :key, :rev, :lease]

  field :name, 1, type: :bytes
  field :key, 2, type: :bytes
  field :rev, 3, type: :int64
  field :lease, 4, type: :int64
end

defmodule V3electionpb.LeaderRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: binary
        }
  defstruct [:name]

  field :name, 1, type: :bytes
end

defmodule V3electionpb.LeaderResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil,
          kv: Mvccpb.KeyValue.t() | nil
        }
  defstruct [:header, :kv]

  field :header, 1, type: Etcdserverpb.ResponseHeader
  field :kv, 2, type: Mvccpb.KeyValue
end

defmodule V3electionpb.ResignRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          leader: V3electionpb.LeaderKey.t() | nil
        }
  defstruct [:leader]

  field :leader, 1, type: V3electionpb.LeaderKey
end

defmodule V3electionpb.ResignResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil
        }
  defstruct [:header]

  field :header, 1, type: Etcdserverpb.ResponseHeader
end

defmodule V3electionpb.ProclaimRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          leader: V3electionpb.LeaderKey.t() | nil,
          value: binary
        }
  defstruct [:leader, :value]

  field :leader, 1, type: V3electionpb.LeaderKey
  field :value, 2, type: :bytes
end

defmodule V3electionpb.ProclaimResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.ResponseHeader.t() | nil
        }
  defstruct [:header]

  field :header, 1, type: Etcdserverpb.ResponseHeader
end

defmodule V3electionpb.Election.Service do
  @moduledoc false
  use GRPC.Service, name: "v3electionpb.Election"

  rpc :Campaign, V3electionpb.CampaignRequest, V3electionpb.CampaignResponse
  rpc :Proclaim, V3electionpb.ProclaimRequest, V3electionpb.ProclaimResponse
  rpc :Leader, V3electionpb.LeaderRequest, V3electionpb.LeaderResponse
  rpc :Observe, V3electionpb.LeaderRequest, stream(V3electionpb.LeaderResponse)
  rpc :Resign, V3electionpb.ResignRequest, V3electionpb.ResignResponse
end

defmodule V3electionpb.Election.Stub do
  @moduledoc false
  use GRPC.Stub, service: V3electionpb.Election.Service
end
