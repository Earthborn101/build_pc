defmodule BuildPcWeb.PageView do
  use BuildPcWeb, :view

  def render(_, %{result: result}) do
    result
  end
end
