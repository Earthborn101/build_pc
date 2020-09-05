defmodule Contexts.ValidationContext do
    @moduledoc false
  
    def valid_changeset({true, changeset}), do: {changeset.changes, changeset}
    def valid_changeset({false, changeset}), do: {:error, changeset}
end