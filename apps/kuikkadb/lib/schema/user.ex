defmodule KuikkaDB.Schema.User do
    use Ecto.Schema
    import Ecto.Changeset
    
    schema "user" do
        belongs_to :permission_id, KuikkaDB.Schema.Permission
        belongs_to :fireteam_id, KuikkaDB.Schema.Fireteam
        belongs_to :fireteamrole_id, KuikkaDB.Schema.Fireteamrole
        field :username, :string
        field :password, :string
        field :email, :string
        field :imageurl, :string
        field :signature, :string
    end
    def changeset(user, params \\%{}) do
        user
        |> cast(params, [:username, :password, :email,:imageurl, :signature, :permission_id, :fireteam_id, :fireteamrole_id])
        |> validate_required([:username, :email, :password])
        |> validate_format(:email, ~r/@/)
        |> foreing_key_constrait([:permission_id, :fireteam_id,:fireteamrole_id])
    end
end