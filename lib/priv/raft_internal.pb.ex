defmodule Etcdserverpb.RequestHeader do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          ID: non_neg_integer,
          username: String.t(),
          auth_revision: non_neg_integer
        }
  defstruct [:ID, :username, :auth_revision]

  field :ID, 1, type: :uint64
  field :username, 2, type: :string
  field :auth_revision, 3, type: :uint64
end

defmodule Etcdserverpb.InternalRaftRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          header: Etcdserverpb.RequestHeader.t() | nil,
          ID: non_neg_integer,
          v2: Etcdserverpb.Request.t() | nil,
          range: Etcdserverpb.RangeRequest.t() | nil,
          put: Etcdserverpb.PutRequest.t() | nil,
          delete_range: Etcdserverpb.DeleteRangeRequest.t() | nil,
          txn: Etcdserverpb.TxnRequest.t() | nil,
          compaction: Etcdserverpb.CompactionRequest.t() | nil,
          lease_grant: Etcdserverpb.LeaseGrantRequest.t() | nil,
          lease_revoke: Etcdserverpb.LeaseRevokeRequest.t() | nil,
          alarm: Etcdserverpb.AlarmRequest.t() | nil,
          lease_checkpoint: Etcdserverpb.LeaseCheckpointRequest.t() | nil,
          auth_enable: Etcdserverpb.AuthEnableRequest.t() | nil,
          auth_disable: Etcdserverpb.AuthDisableRequest.t() | nil,
          authenticate: Etcdserverpb.InternalAuthenticateRequest.t() | nil,
          auth_user_add: Etcdserverpb.AuthUserAddRequest.t() | nil,
          auth_user_delete: Etcdserverpb.AuthUserDeleteRequest.t() | nil,
          auth_user_get: Etcdserverpb.AuthUserGetRequest.t() | nil,
          auth_user_change_password: Etcdserverpb.AuthUserChangePasswordRequest.t() | nil,
          auth_user_grant_role: Etcdserverpb.AuthUserGrantRoleRequest.t() | nil,
          auth_user_revoke_role: Etcdserverpb.AuthUserRevokeRoleRequest.t() | nil,
          auth_user_list: Etcdserverpb.AuthUserListRequest.t() | nil,
          auth_role_list: Etcdserverpb.AuthRoleListRequest.t() | nil,
          auth_role_add: Etcdserverpb.AuthRoleAddRequest.t() | nil,
          auth_role_delete: Etcdserverpb.AuthRoleDeleteRequest.t() | nil,
          auth_role_get: Etcdserverpb.AuthRoleGetRequest.t() | nil,
          auth_role_grant_permission: Etcdserverpb.AuthRoleGrantPermissionRequest.t() | nil,
          auth_role_revoke_permission: Etcdserverpb.AuthRoleRevokePermissionRequest.t() | nil
        }
  defstruct [
    :header,
    :ID,
    :v2,
    :range,
    :put,
    :delete_range,
    :txn,
    :compaction,
    :lease_grant,
    :lease_revoke,
    :alarm,
    :lease_checkpoint,
    :auth_enable,
    :auth_disable,
    :authenticate,
    :auth_user_add,
    :auth_user_delete,
    :auth_user_get,
    :auth_user_change_password,
    :auth_user_grant_role,
    :auth_user_revoke_role,
    :auth_user_list,
    :auth_role_list,
    :auth_role_add,
    :auth_role_delete,
    :auth_role_get,
    :auth_role_grant_permission,
    :auth_role_revoke_permission
  ]

  field :header, 100, type: Etcdserverpb.RequestHeader
  field :ID, 1, type: :uint64
  field :v2, 2, type: Etcdserverpb.Request
  field :range, 3, type: Etcdserverpb.RangeRequest
  field :put, 4, type: Etcdserverpb.PutRequest
  field :delete_range, 5, type: Etcdserverpb.DeleteRangeRequest
  field :txn, 6, type: Etcdserverpb.TxnRequest
  field :compaction, 7, type: Etcdserverpb.CompactionRequest
  field :lease_grant, 8, type: Etcdserverpb.LeaseGrantRequest
  field :lease_revoke, 9, type: Etcdserverpb.LeaseRevokeRequest
  field :alarm, 10, type: Etcdserverpb.AlarmRequest
  field :lease_checkpoint, 11, type: Etcdserverpb.LeaseCheckpointRequest
  field :auth_enable, 1000, type: Etcdserverpb.AuthEnableRequest
  field :auth_disable, 1011, type: Etcdserverpb.AuthDisableRequest
  field :authenticate, 1012, type: Etcdserverpb.InternalAuthenticateRequest
  field :auth_user_add, 1100, type: Etcdserverpb.AuthUserAddRequest
  field :auth_user_delete, 1101, type: Etcdserverpb.AuthUserDeleteRequest
  field :auth_user_get, 1102, type: Etcdserverpb.AuthUserGetRequest
  field :auth_user_change_password, 1103, type: Etcdserverpb.AuthUserChangePasswordRequest
  field :auth_user_grant_role, 1104, type: Etcdserverpb.AuthUserGrantRoleRequest
  field :auth_user_revoke_role, 1105, type: Etcdserverpb.AuthUserRevokeRoleRequest
  field :auth_user_list, 1106, type: Etcdserverpb.AuthUserListRequest
  field :auth_role_list, 1107, type: Etcdserverpb.AuthRoleListRequest
  field :auth_role_add, 1200, type: Etcdserverpb.AuthRoleAddRequest
  field :auth_role_delete, 1201, type: Etcdserverpb.AuthRoleDeleteRequest
  field :auth_role_get, 1202, type: Etcdserverpb.AuthRoleGetRequest
  field :auth_role_grant_permission, 1203, type: Etcdserverpb.AuthRoleGrantPermissionRequest
  field :auth_role_revoke_permission, 1204, type: Etcdserverpb.AuthRoleRevokePermissionRequest
end

defmodule Etcdserverpb.EmptyResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{}
  defstruct []
end

defmodule Etcdserverpb.InternalAuthenticateRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: String.t(),
          password: String.t(),
          simple_token: String.t()
        }
  defstruct [:name, :password, :simple_token]

  field :name, 1, type: :string
  field :password, 2, type: :string
  field :simple_token, 3, type: :string
end
