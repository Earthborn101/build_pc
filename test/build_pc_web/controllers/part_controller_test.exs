defmodule BuildPcWeb.PartControllerTest do
    use BuildPcWeb.ConnCase
  
    setup do
        insert_brands()
        insert_parts()
        
        {:ok, %{}}
    end

    defp insert_brands do
        brands = [
            %{
                code: "AMD",
                name: "Advanced Micro Devices",
                version: "1"
            },
            %{
                code: "INTEL",
                name: "Intel",
                version: "1"
            },
            %{
                code: "NVIDIA",
                name: "Nvidia",
                version: "1"
            },
            %{
                code: "ROG",
                name: "ROG - Republic of Gamers",
                version: "1"
            },
            %{
                code: "SAPPHIRE",
                name: "SAPPHIRE Technology Limited",
                version: "1"
            }
        ]

        brands
        |> Enum.map(&(
            insert(:brands,
                code: &1.code, 
                name: &1.name,
                version: &1.version
            )
        ))
    end

    defp insert_parts do
        parts = [
            %{
                code: "0000000001",
                name: "SAPPHIRE NITRO+ RX 5700 XT 8G GDDR6",
                type: "PCP",
                part_type: "GPU",
                price: "25570.00",
                brand_code: "SAPPHIRE",
                version: "1"
            },
            %{
                code: "0000000002",
                name: "ROG-STRIX-RTX2080TI-O11G-GAMING",
                type: "PCP",
                part_type: "GPU",
                price: "95645.87",
                brand_code: "ROG",
                version: "1"
            },
            %{
                code: "0000000003",
                name: "AMD RYZEN 9 3950X",
                type: "PCP",
                part_type: "CPU",
                price: "43900.00",
                brand_code: "AMD",
                version: "1"
            },
            %{
                code: "0000000004",
                name: "Intel Core i9-10900KF Processor",
                type: "PCP",
                part_type: "CPU",
                price: "25768.38",
                brand_code: "INTEL",
                version: "1"
            },
        ]

        parts
        |> Enum.map(&(
            insert(:parts,
                code: &1.code,
                name: &1.name,
                type: &1.type,
                part_type: &1.part_type,
                price: &1.price,
                brand_code: &1.brand_code,
                version: &1.version
            )
        ))
    end

    describe "Search-parts" do
        test "Valid Params" do
            params = %{
                search_value: "",
                types: [],
                part_types: [],
                specific_part: "",
                specific_part_types: [],
                min_data: "",
                max_data: "",
                brands: [],
                min_price: "",
                max_price: "",
                page_number: "1",
                display_per_page: "10",
                order_by: "asc",
                sort_by: "name"
            }

            conn = post(build_conn(), "/api/v1/parts/search-parts", params)
            response = json_response(conn, 200)
            search_result = response["search_result"]
            count = response["total_count"]
            assert List.first(search_result)["name"] == "AMD RYZEN 9 3950X"
            assert count == 4
        end

        test "Valid Params/with Min Price" do
            params = %{
                search_value: "",
                types: [],
                part_types: [],
                specific_part: "",
                specific_part_types: [],
                min_data: "",
                max_data: "",
                brands: [],
                min_price: "50000.00",
                max_price: "",
                page_number: "1",
                display_per_page: "10",
                order_by: "asc",
                sort_by: "name"
            }

            conn = post(build_conn(), "/api/v1/parts/search-parts", params)
            response = json_response(conn, 200)
            search_result = response["search_result"]
            count = response["total_count"]
            assert List.first(search_result)["name"] == "ROG-STRIX-RTX2080TI-O11G-GAMING"
            assert count == 1
        end
        test "Valid Params/with Max Price" do
            params = %{
                search_value: "",
                types: [],
                part_types: [],
                specific_part: "",
                specific_part_types: [],
                min_data: "",
                max_data: "",
                brands: [],
                min_price: "",
                max_price: "30000",
                page_number: "1",
                display_per_page: "10",
                order_by: "asc",
                sort_by: "name"
            }

            conn = post(build_conn(), "/api/v1/parts/search-parts", params)
            response = json_response(conn, 200)
            search_result = response["search_result"]
            count = response["total_count"]
            assert List.first(search_result)["name"] == "Intel Core i9-10900KF Processor"
            assert count == 2
        end
        test "Valid Params/with Min and Max Price" do
            params = %{
                search_value: "",
                types: [],
                part_types: [],
                specific_part: "",
                specific_part_types: [],
                min_data: "",
                max_data: "",
                brands: [],
                min_price: "25571",
                max_price: "30000",
                page_number: "1",
                display_per_page: "10",
                order_by: "asc",
                sort_by: "name"
            }

            conn = post(build_conn(), "/api/v1/parts/search-parts", params)
            response = json_response(conn, 200)
            search_result = response["search_result"]
            count = response["total_count"]
            assert List.first(search_result)["name"] == "Intel Core i9-10900KF Processor"
            assert count == 1
        end

        test "Valid Params/with filter brand" do
            params = %{
                search_value: "",
                types: [],
                part_types: [],
                specific_part: "",
                specific_part_types: [],
                min_data: "",
                max_data: "",
                brands: ["SAPPHIRE"],
                min_price: "",
                max_price: "",
                page_number: "1",
                display_per_page: "10",
                order_by: "asc",
                sort_by: "name"
            }

            conn = post(build_conn(), "/api/v1/parts/search-parts", params)
            response = json_response(conn, 200)
            search_result = response["search_result"]
            count = response["total_count"]
            assert List.first(search_result)["name"] == "SAPPHIRE NITRO+ RX 5700 XT 8G GDDR6"
            assert count == 1
        end
    end
  end
  