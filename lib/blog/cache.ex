defmodule Blog.Cache do
  use GenServer

  # Public API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [
        {:post_table, :post_cache_table},
        {:file_table, :file_mapping_table},
        {:post_dir, Application.get_env(:blog, Blog.Endpoint)[:post_folder]}
      ], opts)
  end

  def fetch(slug) do
    case get(slug) do
      {:not_found} -> nil
      {:found, result} -> result
    end
  end

  def fetch_index do
    get_index()
  end

  def update(file) do
    case reload(file) do
      :ok -> :ok
      :err -> :err
    end
  end

  defp get(slug) do
    case GenServer.call(__MODULE__, {:get, slug}) do
      [] -> {:not_found}
      [{_slug, result}] -> {:found, result}
    end
  end

  defp get_index do
    case GenServer.call(__MODULE__, {:get_index}) do
      posts when is_list(posts) -> posts
      _ -> []
    end
  end

  defp reload(file) do
    case GenServer.call(__MODULE__, {:reload, file}) do
      :ok -> :ok
      :err -> :err
    end
  end

  # Server Callbacks

  def init(args) do
    [
      {:post_table, post_table},
      {:file_table, file_table},
      {:post_dir, post_dir}
    ] = args

    :ets.new(post_table, [:set, :private, :named_table])
    :ets.new(file_table, [:set, :private, :named_table])

    init_posts(post_dir, post_table, file_table)

    {:ok, %{post_table: post_table, file_table: file_table, post_dir: post_dir}}
  end

  defp init_posts(dir, post_table, file_table) do
    case read_dir(dir) do
      [] -> nil
      posts when is_list(posts) ->
        Enum.each(posts, fn(post) -> insert(post, post_table, file_table) end)
    end
  end

  def handle_call({:get, slug}, _from, state) do
    %{post_table: post_table} = state
    result = :ets.lookup(post_table, slug)
    {:reply, result, state}
  end

  def handle_call({:reload, file}, _from, state) do
    case read_file(file) do
      {:ok, result} ->
        %{post_table: post_table, file_table: file_table} = state
        update_file_mapping(result, post_table, file_table)
        insert(result, post_table, file_table)
        {:reply, :ok, state}
      {:err, nil} ->
        {:reply, :err, state}
    end
  end

  def handle_call({:get_index}, _from, state) do
    %{post_table: post_table} = state

    posts = :ets.match(post_table, {:"$1", :"_"})
      |> uncrustify_slugs
      |> Enum.reverse
      |> fetch_posts(post_table)

    {:reply, posts, state}
  end

  defp update_file_mapping(post, post_table, file_table) do
    case :ets.lookup(file_table, post.file) do
      [{_file, slug}] ->
        unless post.slug == slug do
          :ets.delete(post_table, slug)
        end
      _ -> nil
    end
  end

  defp uncrustify_slugs([]) do [] end
  defp uncrustify_slugs([head|tail]) when is_list(head) do
    [Enum.at(head, 0)] ++ uncrustify_slugs(tail)
  end

  defp fetch_posts([], _post_table) do [] end
  defp fetch_posts([slug|tail], post_table) do
    [{_, %{slug: slug, title: title, subtitle: subtitle}}] = :ets.lookup(post_table, slug)
    [%{slug: slug, title: title, subtitle: subtitle}] ++ fetch_posts(tail, post_table)
  end

  defp insert(post = %{slug: slug, file: file, title: _, subtitle: _, text: _}, post_table, file_table) do
    :ets.insert(post_table, {slug, post})
    :ets.insert(file_table, {file, slug})
  end

  defp read_dir(dir) do
    files = Path.wildcard(dir <> "/*.md") |> Enum.reverse
    read_dir_rec_helper(files)
  end

  defp read_dir_rec_helper([]) do [] end
  defp read_dir_rec_helper([head|tail]) do
    case read_file(head) do
      {:ok, result} -> [result] ++ read_dir_rec_helper(tail)
      _ -> read_dir_rec_helper(tail)
    end
  end

  defp read_file(file) do
    case File.read(file) do
      {:ok, result} ->
        [title, subtitle, text] = String.split(result, "\n", parts: 3)
        slug = gen_slug(title)
        text = Earmark.as_html!(text, %Earmark.Options{code_class_prefix: "language-"})
        {:ok, %{slug: slug, file: file, title: title, subtitle: subtitle, text: text}}
      _ -> {:err, nil}
    end
  end

  defp gen_slug(title) do
    String.downcase(title) |> String.replace(~r/[^a-z-0-9 ]+/i, "") |> String.replace(" ", "-")
  end
end
