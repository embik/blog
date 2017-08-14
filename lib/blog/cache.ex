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
        {:post_dir, Application.get_env(:blog, BlogWeb.Endpoint)[:post_folder]}
      ], opts)
  end

  def fetch_page(page) when is_number(page) do
    get_page(page)
  end

  def get(slug) do
    case GenServer.call(__MODULE__, {:get, slug}) do
      [] -> {:not_found}
      result when is_map(result) -> {:found, result}
    end
  end

  def get_page(page) when is_number(page) do
    case GenServer.call(__MODULE__, {:get_page, page}) do
      {posts, pages} when is_list(posts) -> {posts, pages}
      _ -> {[], 0}
    end
  end

  def get_tag_page(tag, page) when is_number(page) do
    case GenServer.call(__MODULE__, {:get_tag_page, tag, page}) do
      {posts, pages} when is_list(posts) -> {posts, pages}
      _ -> {[], 0}
    end
  end

  def reload(file) do
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

    state = %{post_table: post_table, meta_table: meta_table, post_dir: post_dir}

    Db.init(state)
    init_posts(state)
    {:ok, state}
  end

  defp init_posts(state) do
    %{post_dir: post_dir} = state

    case Parser.read_dir(post_dir) do
      [] -> nil
      posts when is_list(posts) ->
        Enum.each(posts, fn(post) -> Db.insert(post, state) end)
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

  def handle_call({:get_tag_page, tag, page}, _from, state) when is_number(page) do
    result = Db.get_tag_page(tag, page, state)
    {:reply, result, state}
  end

  def handle_call({:reload, file}, _from, state) do
    case Parser.read_file(file) do
      {:ok, _post} ->
        Db.flush(state)
        init_posts(state)
        {:reply, :ok, state}
      {:err, nil} -> {:reply, :err, state}
    end
  end
end
