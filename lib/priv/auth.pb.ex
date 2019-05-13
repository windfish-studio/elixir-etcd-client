defmodule Authpb.User do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: binary,
          password: binary,
          roles: [String.t()]
        }
  defstruct [:name, :password, :roles]

  field :name, 1, type: :bytes
  field :password, 2, type: :bytes
  field :roles, 3, repeated: true, type: :string
end

defmodule Authpb.Permission do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          permType: atom | integer,
          key: binary,
          range_end: binary
        }
  defstruct [:permType, :key, :range_end]

  field :permType, 1, type: Authpb.Permission.Type, enum: true
  field :key, 2, type: :bytes
  field :range_end, 3, type: :bytes
end

defmodule Authpb.Permission.Type do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  field :READ, 0
  field :WRITE, 1
  field :READWRITE, 2
end

defmodule Authpb.Role do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: binary,
          keyPermission: [Authpb.Permission.t()]
        }
  defstruct [:name, :keyPermission]

  field :name, 1, type: :bytes
  field :keyPermission, 2, repeated: true, type: Authpb.Permission
end
