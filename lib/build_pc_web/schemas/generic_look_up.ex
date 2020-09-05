defmodule BuildPc.Schemas.GenericLookUp do
    @moduledoc false
  
    use BuildPc.Schema
  
    @primary_key {:code, :string, []}
    schema "generic_look_ups" do
      field(:type, :string)
      field(:name, :string)
      field(:description, :string)
  
      timestamps()
    end
  
    def changeset(struct, params \\ %{}) do
      struct
      |> cast(params, [
        :code,
        :type,
        :name,
        :description
      ])
      |> validate_required([
        :code,
        :type,
        :name,
        :description
      ])
    end
  end
  