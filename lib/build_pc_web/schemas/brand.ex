defmodule BuildPc.Schemas.Brand do
    @moduledoc false

    use BuildPc.Schema

    @primary_key {:code, :string, []}
    schema "brands" do
        field :name, :string
        field :description, :string
        field :profile_image, :string
        field :version, :string
        field :inserted_by, :string
        field :updated_by, :string

        timestamps()
    end

    def changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [
            :code,
            :name, 
            :description, 
            :profile_image, 
            :version, 
            :inserted_by, 
            :updated_by
        ])
    end
end