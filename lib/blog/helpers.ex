defmodule Blog.Helpers do
  def load_svg(category, name) do
    path = "priv/static/images/icons/" <> category <> "/" <> name <> ".svg"
    case File.read(path) do
      {:ok, svg} -> svg
      _ -> "Fehler"
    end
  end
end
