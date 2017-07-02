defmodule Blog.Cache do
  use GenServer

  require Logger
  alias Blog.Cache.Parser
  alias Blog.Cache.Db

  # Public API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [
        {:post_table, :post_cache_table},
        {:meta_table, :meta_table},
        {:post_dir, Application.get_env(:blog, Blog.Endpoint)[:post_folder]}
      ], opts)
  end

  def fetch(slug) do
    case get(slug) do
      {:not_found} -> nil
      {:found, result} -> result
    end
  end

  def fetch_page(page) when is_number(page) do
    get_page(page)
  end

  def update(_file) do
    :ok
  end

  defp get(slug) do
    case GenServer.call(__MODULE__, {:get, slug}) do
      [] -> {:not_found}
      result when is_map(result) -> {:found, result}
    end
  end

  defp get_page(page) when is_number(page) do
    case GenServer.call(__MODULE__, {:get_page, page}) do
      {posts, pages} when is_list(posts) -> {posts, pages}
      _ -> {[], 0}
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
      {:meta_table, meta_table},
      {:post_dir, post_dir}
    ] = args

    :ets.new(post_table, [:ordered_set, :private, :named_table])
    :ets.new(meta_table, [:set, :private, :named_table])

    :ets.insert(meta_table, {"post_list", []})

    init_posts(post_dir, post_table, meta_table)

    {:ok, %{post_table: post_table, meta_table: meta_table, post_dir: post_dir}}
  end

  defp init_posts(dir, post_table, meta_table) do
    case Parser.read_dir(dir) do
      [] -> nil
      posts when is_list(posts) ->
        Enum.each(posts, fn(post) -> Db.insert(post, %{post_table: post_table, meta_table: meta_table}) end)
    end
  end

  def handle_call({:get, slug}, _from, state) do
    {_, result} = Db.get(slug, state)
    {:reply, result, state}
  end

  def handle_call({:get_page, page}, _from, state) when is_number(page) do
    result = Db.get_page(page, state)
    {:reply, result, state}
  end

  def handle_call({:get_tag, tag}, _from, state) do
    {:reply, nil, state}
  end
end
