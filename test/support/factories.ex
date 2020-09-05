defmodule BuildPc.Factory do
    @moduledoc "All mock data used for testing are defined here"
    use ExMachina.Ecto, repo: BuildPc.Repo

    ### Schemas
    alias BuildPc.Schemas.Brand
    alias BuildPc.Schemas.GenericLookUp
    alias BuildPc.Schemas.Part

    def brands_factory do
        %Brand{}
    end

    def generic_look_ups_factory do
        %GenericLookUp{}
    end

    def parts_factory do
        %Part{}
    end
end
