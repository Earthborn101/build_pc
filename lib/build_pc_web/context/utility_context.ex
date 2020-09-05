defmodule Contexts.UtilityContext do
    @moduledoc false
    
    alias Contexts.PartsContext, as: PC  
    alias Ecto.Changeset

    ### Start of Common Validation Params ###

    def validate_params(params, fields, context_key, function_key) do
        {%{}, fields}
        |> Changeset.cast(params, Map.keys(fields))
        |> redirect_validate_context(context_key, function_key)
        |> is_valid_changeset()
    end

    def redirect_validate_context(
        changeset, 
        :parts_context, 
        function_key
    ), do: PC.validate_params(changeset, function_key)

    defp is_valid_changeset(changeset), do: {changeset.valid?, changeset}

    ### End of Common Validation Params ###

    ### Start of Context functions ###

    def context_functions({:error, changeset}, _context_key, _function_key), do: {:error, changeset}
    def context_functions(
        params, 
        :parts_context, 
        function_key
    ), do: PC.context_functions(params, function_key)

    ### End of Context functions ###

    def transform_error_message(changeset) do
        errors =
          Enum.map(changeset.errors, fn {key, {message, _}} ->
            %{
              key => transform_required(key, message)
            }
          end)
    
        Enum.reduce(errors, fn head, tail ->
          Map.merge(head, tail)
        end)
      end
    
    defp transform_required(key, "is required"), do: "Enter #{key}"
    defp transform_required(key, "Select"), do: "Select #{transform_atom(key)}"
    defp transform_required(key, "Enter"), do: "Enter #{transform_atom(key)}"
    defp transform_required(key, "is invalid"), do: "#{transform_atom(key)} is invalid"
    defp transform_required(_key, message), do: message 

    defp transform_atom(key) do
        key
        |> atom_to_string()
        |> String.split("_")
        |> Enum.join(" ")
        |> String.capitalize()
    end
    
    defp atom_to_string(data) do
        data
        |> Atom.to_string()
     
        rescue
        _ ->
          data
    end
end