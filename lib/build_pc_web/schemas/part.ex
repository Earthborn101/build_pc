defmodule BuildPc.Schemas.Part do
    @moduledoc false

    use BuildPc.Schema

    @primary_key {:code, :string, []}
    schema "parts" do
        field :name, :string
        field :description, :string
        field :profile_image, :string
        field :type, :string
        field :part_type, :string
        field :price, :string
        field :version, :string
        field :brand_code, :string
        field :inserted_by, :string
        field :updated_by, :string

        timestamps()
    end

    def changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [
            :name,
            :description,
            :profile_image,
            :type,
            :part_type,
            :price,
            :version,
            :brand_code,
            :inserted_by,
            :updated_by
        ])
    end
end