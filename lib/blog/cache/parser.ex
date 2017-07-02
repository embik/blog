defmodule Blog.Cache.Parser do
  def read_dir(dir) do
    files = Path.wildcard(dir <> "/*.md")
    read_dir_rec_helper(files)
  end

  defp read_dir_rec_helper([]) do [] end
  defp read_dir_rec_helper([head|tail]) do
    case read_file(head) do
      {:ok, result} -> [result] ++ read_dir_rec_helper(tail)
      _ -> read_dir_rec_helper(tail)
    end
  end

  def read_file(file) do
    case File.read(file) do
      {:ok, result} ->
        [meta, content] = String.split(result, "---", parts: 2)

        %{"title" => title,
          "keywords" => keywords,
          "date" => date} = YamlElixir.read_from_string(meta)
        date = Timex.parse!(date, "{YYYY}-{0M}-{0D}")
        slug = gen_slug(title)
        text = Earmark.as_html!(content)

        {:ok, %{slug: slug, file: file, title: title, date: date, keywords: keywords, text: text}}
      _ -> {:err, nil}
    end
  end

  defp gen_slug(title) do
    String.downcase(title) |> String.replace(~r/[^a-z-0-9 ]+/i, "") |> String.replace(" ", "-")
  end
end
