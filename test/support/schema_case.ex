defmodule BuildPcWeb.SchemaCase do
    @moduledoc "Base schema for tests"
    use ExUnit.CaseTemplate
  
    using do
      quote do
        import Ecto
        import Ecto.Changeset
        import Ecto.Query
        import BuildPcWeb.SchemaCase
        import BuildPc.Factory
      end
    end
  
    setup tags do
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(BuildPc.Repo)

      unless tags[:async] do
        Ecto.Adapters.SQL.Sandbox.mode(BuildPc.Repo, {:shared, self()})
      end
  
      :ok
    end
  end
  