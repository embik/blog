defmodule Blog.Cache.Parser do
  alias Blog.Cache.Models.Post
  require Logger

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

        meta = YamlElixir.read_from_string(meta)

        # Required meta information
        %{"title" => title,
          "keywords" => keywords,
          "date" => date,
          "description" => description} = meta

        if String.length(description) > 200 do
          Logger.warn("Post description has exceeded allowed length.\n  File: #{file}\n  Description: #{description}")
        end

        post = %Post{
          slug: gen_slug(title),
          title: title,
          file: file,
          date: Timex.parse!(date, "{YYYY}-{0M}-{0D}"),
          keywords: keywords,
          description: description,
          text: Earmark.as_html!(content, %Earmark.Options{code_class_prefix: "language-"})
        }

        {:ok, post}
      _ -> {:err, nil}
    end
  end

  defp gen_slug(title) do
    String.downcase(title) |> String.replace(~r/[^a-z-0-9 ]+/i, "") |> String.replace(" ", "-")
  end
end
