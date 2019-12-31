defmodule Authpb.UserAddOptions do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          no_password: boolean
        }
  defstruct [:no_password]

  field :no_password, 1, type: :bool
end

defmodule Authpb.User do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: binary,
          password: binary,
          roles: [String.t()],
          options: Authpb.UserAddOptions.t() | nil
        }
  defstruct [:name, :password, :roles, :options]

  field :name, 1, type: :bytes
  field :password, 2, type: :bytes
  field :roles, 3, repeated: true, type: :string
  field :options, 4, type: Authpb.UserAddOptions
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
