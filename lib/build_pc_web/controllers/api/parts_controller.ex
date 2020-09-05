defmodule Api.V1.PartsController do
    use BuildPcWeb, :controller
  
    alias Contexts.PartsContext, as: PC
    alias Contexts.UtilityContext, as: UC
    alias Contexts.ValidationContext, as: VC
  
    alias BuildPcWeb.{
      ErrorView,
      PageView
    }

    ### Start of Controller Functions ###
    def search_parts(conn, params) do
        fields = %{
            search_value: :string,
            types: {:array, :string},
            part_types: {:array, :string},
            specific_part: :string,
            specific_part_types: {:array, :string},
            min_data: :string,
            max_data: :string,
            brands: {:array, :string},
            min_price: :string,
            max_price: :string,
            display_per_page: :integer,
            page_number: :integer,
            order_by: :string,
            sort_by: :string
        }

        params
        |> UC.validate_params(fields, :parts_context, :search_parts)
        |> VC.valid_changeset()
        |> UC.context_functions(:parts_context, :search_parts)
        |> return_result(conn)
    end
    ### End of Controller Functions ###

    ### Start of Return Result Functions ###
    defp return_result({:error, changeset}, conn) do
        conn
        |> put_status(200)
        |> put_view(ErrorView)
        |> render("error.json", error: UC.transform_error_message(changeset))
    end

    defp return_result(params, conn) do
        conn
        |> put_status(200)
        |> put_view(PageView)
        |> render("success.json", result: params)
    end
    ### End of Return Result Functions ###
end