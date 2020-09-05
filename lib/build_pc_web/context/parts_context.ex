defmodule Contexts.PartsContext do
    @moduledoc false
    
    import Ecto.Query, warn: false
    
    ### Repo
    alias BuildPc.Repo

    ### Schemas
    alias BuildPc.Schemas.Brand
    alias BuildPc.Schemas.GenericLookUp
    alias BuildPc.Schemas.Part
    
    alias Ecto.Changeset
    
    ### Start of Validate Params ###
    def validate_params(changeset, :search_parts) do
        changeset
        |> Changeset.validate_required([:display_per_page], message: "Enter display per page")
        |> Changeset.validate_required([:page_number], message: "Enter page number")
        |> Changeset.validate_required([:order_by], message: "Enter order by")
        |> Changeset.validate_required([:sort_by], message: "Enter sort by")
        |> Changeset.validate_number(:display_per_page,
            greater_than: 0,
            message: "Display per page must be greater than 0"
        )
        |> Changeset.validate_number(:page_number,
            greater_than: 0,
            message: "Page number must be greater than 0"
        )
        |> Changeset.validate_inclusion(
            :order_by,
            [
                "asc",
                "desc"
            ],
            message: "Order by is invalid. Allowed values ['asc', 'desc']"
        )
        |> Changeset.validate_inclusion(
            :sort_by,
            [
                "brand_name",
                "name",
                "price"
            ],
            message: "Sort by is invalid. Allowed values ['brand_name', 'name', 'price']"
        )
        |> validate_type()
        |> validate_part_types()
        |> validate_specific_part()
        |> validate_specific_part_types()
        |> validate_ram_storage_memory()
        |> validate_price()
        |> validate_brands()
    end
    ### End of Validate Params ###

    ### Start of Context Functions ###
    def context_functions({%{specific_part: specific_part} = params, changeset}, :search_parts) do
        raise 321
    end

    def context_functions({params, changeset}, :search_parts) do
        search_value = if Map.has_key?(params, :search_value), do: params.search_value, else: ""
        offset = params.page_number * params.display_per_page - params.display_per_page

        params = 
            params
            |> Map.put(:search_value, search_value)
            |> Map.put(:offset, offset)

        params
        |> search_parts()
        |> count_search_parts(params, changeset)
    end

    defp search_parts(params) do
        Part
        |> join_search_parts()
        |> where_ilike_search_parts(params[:search_value])
        |> filter_price(params)
        |> filter_brands(params)
        |> select_search_parts()
        |> offset(^params[:offset])
        |> limit(^params[:display_per_page])
        |> search_parts_order_by(params[:order_by], params[:sort_by])
        |> Repo.all()
    end

    defp count_search_parts([], %{search_value: _search_value}, changeset) do
        changeset =
            changeset
            |> Changeset.add_error(:message, "No records found!")
        
        {:error, changeset}
    end
    defp count_search_parts([], _params, changeset) do
        changeset =
            changeset
            |> Changeset.add_error(:message, "No existing records!")
        
        {:error, changeset}
    end
    defp count_search_parts(parts, params, _changeset) do
        total_count =
            Part
            |> join_search_parts()
            |> where_ilike_search_parts(params[:search_value])
            |> filter_price(params)
            |> filter_brands(params)
            |> select([p, b], count(p.code))
            |> Repo.one()
        
        %{
            total_count: total_count,
            search_result: parts
        }
    end

    defp join_search_parts(query) do
        query
        |> join(:inner, [p], b in Brand, on: b.code == p.brand_code)
    end

    defp where_ilike_search_parts(query, search_value) do
        search_value =
            search_value
            |> String.replace(" ", "%")

        query
        |> where([p, b],
            ilike(p.name, ^"%#{search_value}%") or
            ilike(p.part_type, ^"%#{search_value}%") or
            ilike(p.price, ^"%#{search_value}%") or
            ilike(b.name, ^"%#{search_value}%")
        )
    end

    defp filter_price(query, params) do
        query
        |> filter_min_price(params[:min_price])
        |> filter_max_price(params[:max_price])
    end

    defp filter_min_price(query, min_price) 
    when min_price == nil
    do
        query
    end
    defp filter_min_price(query, min_price) do
        query
        |> where([p, b], fragment("? >= ?", fragment("?::numeric", p.price), ^min_price))
    end

    defp filter_max_price(query, max_price)
    when max_price == nil
    do
        query
    end
    defp filter_max_price(query, max_price) do
        query
        |> where([p, b], fragment("? <= ?", fragment("?::numeric", p.price), ^max_price))
    end

    defp filter_brands(query, %{brands: []}), do: query
    defp filter_brands(query, %{brands: brands}) do
        query
        |> where([p, b], b.code in ^brands)
    end

    defp select_search_parts(query) do
        query
        |> select([p, b], %{
            name: p.name,
            brand_name: b.name,
            price: p.price
        })
    end

    defp search_parts_order_by(query, "asc", "name") do
        query
        |> order_by([p, b], asc: p.name)
    end
    defp search_parts_order_by(query, "asc", "brand_name") do
        query
        |> order_by([p, b], asc: b.name)
    end
    defp search_parts_order_by(query, "asc", "price") do
        query
        |> order_by([p, b], asc: p.price)
    end
    defp search_parts_order_by(query, "desc", "name") do
        query
        |> order_by([p, b], desc: p.name)
    end
    defp search_parts_order_by(query, "desc", "brand_name") do
        query
        |> order_by([p, b], desc: b.name)
    end
    defp search_parts_order_by(query, "desc", "price") do
        query
        |> order_by([p, b], desc: p.price)
    end
    ### End of Context Functions ###

    ### Start of Search Parts Validation Functions ###
    defp validate_type(%{changes: %{types: []}} = changeset), do: changeset
    defp validate_type(%{changes: %{types: type}} = changeset) do
        type
        |> Enum.uniq()
        |> Enum.filter(&(&1 not in ["PRP", "PCP"]))
        |> validate_error_list(changeset, :type)
    end

    defp validate_part_types(%{changes: %{part_types: []}} = changeset), do: changeset
    defp validate_part_types(%{changes: %{part_types: part_type}} = changeset) do
        part_type
        |> Enum.uniq()
        |> Enum.filter(&(&1 not in [
                "CPU", 
                "GPU", 
                "RAM", 
                "PSU", 
                "FAN", 
                "CPUC", 
                "CASE", 
                "MOBO", 
                "SDD", 
                "HDD",
                "WCP",
                "MNT",
                "MOS",
                "KYB",
                "HST",
                "Others"
            ]
        ))
        |> validate_error_list(changeset, :part_type)
    end
    defp validate_part_types(changeset), do: changeset

    defp validate_specific_part(%{changes: %{specific_part: specific_part}} = changeset) do
        changeset
        |> Changeset.validate_inclusion(
            :specific_part, 
            [
                "CPU", 
                "GPU", 
                "RAM", 
                "PSU", 
                "FAN", 
                "CPUC", 
                "CASE", 
                "MOBO", 
                "SDD", 
                "HDD",
                "WCP",
                "MNT",
                "MOS",
                "KYB",
                "HST",
                "Others"
            ],
            message: "Invalid specific part: #{specific_part}"
        )
    end
    defp validate_specific_part(changeset), do: changeset

    defp validate_specific_part_types(%{changes: %{
        specific_part: specific_part,
        specific_part_types: specific_part_types
    }} = changeset) when specific_part_types !== [] do
        changeset
        |> validate_specific_part_types(specific_part_types, specific_part)
    end
    defp validate_specific_part_types(changeset), do: changeset

    ### Motherboard
    defp validate_specific_part_types(changeset, specific_part_types, "MOBO") do
        specific_part_types
        |> Enum.uniq()
        |> Enum.filter(&(&1 not in ["EATX", "MATX", "ITX", "ATX", "DTX"]))
        |> validate_error_list(changeset, :specific_part_types)
    end

    ### Power Supply
    defp validate_specific_part_types(changeset, specific_part_types, "PSU") do
        specific_part_types
        |> Enum.uniq()
        |> Enum.filter(&(&1 not in [
            "80PLUS",
            "BRONZE",
            "SILVER",
            "GOLD",
            "PLATINUM",
            "TITANIUM",
            "OTHERS"
        ]))
        |> validate_error_list(changeset, :specific_part_types)
    end

    ### SDD
    defp validate_specific_part_types(changeset, specific_part_types, "SDD") do
        specific_part_types
        |> Enum.uniq()
        |> Enum.filter(&(&1 not in ["SSD", "NVME"]))
        |> validate_error_list(changeset, :specific_part_types)
    end

    ### Keyboard
    defp validate_specific_part_types(changeset, specific_part_types, "KYB") do
        specific_part_types
        |> Enum.uniq()
        |> Enum.filter(&(&1 not in ["60_percent", "65_percent", "TKL", "full"]))
        |> validate_error_list(changeset, :specific_part_types)
    end

    defp validate_ram_storage_memory(%{changes: %{
        specific_part_type: "RAM"
    }} = changeset) do
        changeset
        |> validate_min_ram()
        |> validate_max_ram()
        |> validate_min_max_ram()
    end

    defp validate_ram_storage_memory(changeset), do: changeset

    defp validate_min_ram(%{changes: %{min_data: min_data}} = changeset) do
        min_data
        |> Float.parse()
        |> validate_ram_error(changeset, :min_data)
    end

    defp validate_max_ram(%{changes: %{max_data: max_data}} = changeset) do
        max_data
        |> Float.parse()
        |> validate_ram_error(changeset, :max_data)
    end

    defp validate_min_max_ram(%{changes: %{
        max_data: max_data,
        min_data: min_data
    }} = changeset) do
        if min_data <= max_data do
            changeset
        else
            changeset
            |> Changeset.add_error(:min_price, "Min data must be lower than or equal max data")
        end
    end

    defp validate_price(changeset) do
        changeset
        |> validate_min_price()
        |> validate_max_price()
        |> validate_min_max_price()
    end

    defp validate_min_price(%{changes: %{min_price: min_price}} = changeset) do
        min_price
        |> Float.parse()
        |> validate_price_error(changeset, :min_price)
    end
    defp validate_min_price(changeset), do: changeset

    defp validate_max_price(%{changes: %{max_price: max_price}} = changeset) do
        max_price
        |> Float.parse()
        |> validate_price_error(changeset, :max_price)
    end
    defp validate_max_price(changeset), do: changeset

    defp validate_min_max_price(%{changes: %{min_price: min_price, max_price: max_price}} = changeset) do
        if min_price <= max_price do
            changeset
        else
            changeset
            |> Changeset.add_error(
                :min_price, 
                "Min price must be lower than or equal max price"
            )
        end
    end
    defp validate_min_max_price(changeset), do: changeset

    defp validate_brands(%{changes: %{brands: []}} = changeset), do: changeset
    defp validate_brands(%{changes: %{brands: brands}} = changeset) do
        brand_list =
            Brand
            |> where([b], b.code in ^brands)
            |> select([b], b.code)
            |> Repo.all()

        brands = brands -- brand_list

        brands
        |> validate_error_list(changeset, :brands)
    end
    defp validate_brands(changeset), do: changeset

    ### End of Search Parts Validation Functions ###

    ### Start of Common Functions ###
    defp validate_error_list([], changeset, _key), do: changeset
    defp validate_error_list(error, changeset, key) do
        error = Enum.join(error, ", ")
        changeset
        |> Changeset.add_error(key, "Invalid type/s: #{error}")
    end

    defp validate_ram_error({memory, ""}, changeset, key) do
        changeset
        |> Changeset.put_change(key, memory)
    end

    defp validate_ram_error(_, changeset, key) do
        changeset
        |> Changeset.add_error(key, "Invalid memory")
    end

    defp validate_price_error({price, ""}, changeset, key) do 
        changeset
        |> Changeset.put_change(key, price)
    end
    defp validate_price_error(_, changeset, key) do
        changeset
        |> Changeset.add_error(key, "Invalid amount")
    end
    ### End of Common Functions ###
end
