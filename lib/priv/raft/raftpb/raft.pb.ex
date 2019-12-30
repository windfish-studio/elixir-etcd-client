defmodule Raftpb.EntryType do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto2

  field :EntryNormal, 0
  field :EntryConfChange, 1
  field :EntryConfChangeV2, 2
end

defmodule Raftpb.MessageType do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto2

  field :MsgHup, 0
  field :MsgBeat, 1
  field :MsgProp, 2
  field :MsgApp, 3
  field :MsgAppResp, 4
  field :MsgVote, 5
  field :MsgVoteResp, 6
  field :MsgSnap, 7
  field :MsgHeartbeat, 8
  field :MsgHeartbeatResp, 9
  field :MsgUnreachable, 10
  field :MsgSnapStatus, 11
  field :MsgCheckQuorum, 12
  field :MsgTransferLeader, 13
  field :MsgTimeoutNow, 14
  field :MsgReadIndex, 15
  field :MsgReadIndexResp, 16
  field :MsgPreVote, 17
  field :MsgPreVoteResp, 18
end

defmodule Raftpb.ConfChangeTransition do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto2

  field :ConfChangeTransitionAuto, 0
  field :ConfChangeTransitionJointImplicit, 1
  field :ConfChangeTransitionJointExplicit, 2
end

defmodule Raftpb.ConfChangeType do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto2

  field :ConfChangeAddNode, 0
  field :ConfChangeRemoveNode, 1
  field :ConfChangeUpdateNode, 2
  field :ConfChangeAddLearnerNode, 3
end

defmodule Raftpb.Entry do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          Term: non_neg_integer,
          Index: non_neg_integer,
          Type: atom | integer,
          Data: binary
        }
  defstruct [:Term, :Index, :Type, :Data]

  field :Term, 2, optional: true, type: :uint64
  field :Index, 3, optional: true, type: :uint64
  field :Type, 1, optional: true, type: Raftpb.EntryType, enum: true
  field :Data, 4, optional: true, type: :bytes
end

defmodule Raftpb.SnapshotMetadata do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          conf_state: Raftpb.ConfState.t() | nil,
          index: non_neg_integer,
          term: non_neg_integer
        }
  defstruct [:conf_state, :index, :term]

  field :conf_state, 1, optional: true, type: Raftpb.ConfState
  field :index, 2, optional: true, type: :uint64
  field :term, 3, optional: true, type: :uint64
end

defmodule Raftpb.Snapshot do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          data: binary,
          metadata: Raftpb.SnapshotMetadata.t() | nil
        }
  defstruct [:data, :metadata]

  field :data, 1, optional: true, type: :bytes
  field :metadata, 2, optional: true, type: Raftpb.SnapshotMetadata
end

defmodule Raftpb.Message do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          type: atom | integer,
          to: non_neg_integer,
          from: non_neg_integer,
          term: non_neg_integer,
          logTerm: non_neg_integer,
          index: non_neg_integer,
          entries: [Raftpb.Entry.t()],
          commit: non_neg_integer,
          snapshot: Raftpb.Snapshot.t() | nil,
          reject: boolean,
          rejectHint: non_neg_integer,
          context: binary
        }
  defstruct [
    :type,
    :to,
    :from,
    :term,
    :logTerm,
    :index,
    :entries,
    :commit,
    :snapshot,
    :reject,
    :rejectHint,
    :context
  ]

  field :type, 1, optional: true, type: Raftpb.MessageType, enum: true
  field :to, 2, optional: true, type: :uint64
  field :from, 3, optional: true, type: :uint64
  field :term, 4, optional: true, type: :uint64
  field :logTerm, 5, optional: true, type: :uint64
  field :index, 6, optional: true, type: :uint64
  field :entries, 7, repeated: true, type: Raftpb.Entry
  field :commit, 8, optional: true, type: :uint64
  field :snapshot, 9, optional: true, type: Raftpb.Snapshot
  field :reject, 10, optional: true, type: :bool
  field :rejectHint, 11, optional: true, type: :uint64
  field :context, 12, optional: true, type: :bytes
end

defmodule Raftpb.HardState do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          term: non_neg_integer,
          vote: non_neg_integer,
          commit: non_neg_integer
        }
  defstruct [:term, :vote, :commit]

  field :term, 1, optional: true, type: :uint64
  field :vote, 2, optional: true, type: :uint64
  field :commit, 3, optional: true, type: :uint64
end

defmodule Raftpb.ConfState do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          voters: [non_neg_integer],
          learners: [non_neg_integer],
          voters_outgoing: [non_neg_integer],
          learners_next: [non_neg_integer],
          auto_leave: boolean
        }
  defstruct [:voters, :learners, :voters_outgoing, :learners_next, :auto_leave]

  field :voters, 1, repeated: true, type: :uint64
  field :learners, 2, repeated: true, type: :uint64
  field :voters_outgoing, 3, repeated: true, type: :uint64
  field :learners_next, 4, repeated: true, type: :uint64
  field :auto_leave, 5, optional: true, type: :bool
end

defmodule Raftpb.ConfChange do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          type: atom | integer,
          node_id: non_neg_integer,
          context: binary,
          id: non_neg_integer
        }
  defstruct [:type, :node_id, :context, :id]

  field :type, 2, optional: true, type: Raftpb.ConfChangeType, enum: true
  field :node_id, 3, optional: true, type: :uint64
  field :context, 4, optional: true, type: :bytes
  field :id, 1, optional: true, type: :uint64
end

defmodule Raftpb.ConfChangeSingle do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          type: atom | integer,
          node_id: non_neg_integer
        }
  defstruct [:type, :node_id]

  field :type, 1, optional: true, type: Raftpb.ConfChangeType, enum: true
  field :node_id, 2, optional: true, type: :uint64
end

defmodule Raftpb.ConfChangeV2 do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          transition: atom | integer,
          changes: [Raftpb.ConfChangeSingle.t()],
          context: binary
        }
  defstruct [:transition, :changes, :context]

  field :transition, 1, optional: true, type: Raftpb.ConfChangeTransition, enum: true
  field :changes, 2, repeated: true, type: Raftpb.ConfChangeSingle
  field :context, 3, optional: true, type: :bytes
end
