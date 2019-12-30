defmodule Membershippb.RaftAttributes do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          peer_urls: [String.t()],
          is_learner: boolean
        }
  defstruct [:peer_urls, :is_learner]

  field :peer_urls, 1, repeated: true, type: :string
  field :is_learner, 2, type: :bool
end

defmodule Membershippb.Attributes do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: String.t(),
          client_urls: [String.t()]
        }
  defstruct [:name, :client_urls]

  field :name, 1, type: :string
  field :client_urls, 2, repeated: true, type: :string
end

defmodule Membershippb.Member do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          ID: non_neg_integer,
          raft_attributes: Membershippb.RaftAttributes.t() | nil,
          member_attributes: Membershippb.Attributes.t() | nil
        }
  defstruct [:ID, :raft_attributes, :member_attributes]

  field :ID, 1, type: :uint64
  field :raft_attributes, 2, type: Membershippb.RaftAttributes
  field :member_attributes, 3, type: Membershippb.Attributes
end

defmodule Membershippb.ClusterVersionSetRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          ver: String.t()
        }
  defstruct [:ver]

  field :ver, 1, type: :string
end

defmodule Membershippb.ClusterMemberAttrSetRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          member_ID: non_neg_integer,
          member_attributes: Membershippb.Attributes.t() | nil
        }
  defstruct [:member_ID, :member_attributes]

  field :member_ID, 1, type: :uint64
  field :member_attributes, 2, type: Membershippb.Attributes
end
