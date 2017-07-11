defmodule Blog.Cache.Db do
  import Blog.Cache.Models
  require Logger

  @post_list "post_list"

  def init(state) do
    Logger.debug("Initializing Blog.Cache databases")
    %{post_table: post_table, meta_table: meta_table} = state
    :ets.new(post_table, [:set, :private, :named_table])
    :ets.new(meta_table, [:set, :private, :named_table])

    :ets.insert(meta_table, {@post_list, []})
  end

  def flush(state) do
    Logger.debug("Flushing Blog.Cache databases")
    %{post_table: post_table, meta_table: meta_table} = state
    :ets.delete_all_objects(post_table)
    :ets.delete_all_objects(meta_table)

    :ets.insert(meta_table, {@post_list, []})
  end

  def get(slug, state) do
    %{post_table: post_table} = state
    case :ets.lookup(post_table, slug) do
      [{_, post}] -> {:ok, post}
      _ -> {:err, nil}
    end
  end

  def get_page(page, state) when is_number(page) do
    %{meta_table: meta_table} = state

    [{_, post_list}] = :ets.lookup(meta_table, @post_list)
    post_list = Enum.reverse(post_list)
    list_length = length(post_list)
    start_pos = (page - 1) * 5
    pages = list_length |> div(5) |> Kernel.+(1)

    posts =
      case page <= pages do
        true -> Enum.drop(post_list, start_pos) |> Enum.take(5) |> fetch_posts(state)
        false -> []
      end

    {posts, pages}
  end

  def get_tag_page(tag, page, state) when is_number(page) do
    %{meta_table: meta_table} = state

    post_list =
      case :ets.lookup(meta_table, tag) do
        [{_, post_list}] when is_list(post_list) -> Enum.reverse(post_list)
        _ -> []
      end

    list_length = length(post_list)

    start_pos = (page - 1) * 5
    pages = list_length |> div(5) |> Kernel.+(1)

    posts =
      case page <= pages do
        true -> Enum.drop(post_list, start_pos) |> Enum.take(5) |> fetch_posts(state)
        false -> []
      end

    {posts, pages}
  end

  defp fetch_posts([], _state), do: []
  defp fetch_posts([slug|tail], state) do
    case get(slug, state) do
      {:ok, post} -> [post] ++ fetch_posts(tail, state)
      {:err, _} -> fetch_posts(tail, state)
    end
  end

  def insert(post, state) do
    if is_post?(post) do
      %{post_table: post_table, meta_table: meta_table} = state
      [{_, post_list}] = :ets.lookup(meta_table, @post_list)
      post_list = post_list ++ [post.slug]

      :ets.insert(post_table, {post.slug, post})
      :ets.insert(meta_table, {@post_list, post_list})

      for keyword <- post.keywords do
        tag_post_list =
          case :ets.lookup(meta_table, keyword) do
            [{_, list}] when is_list(list) -> list
            _ -> []
          end
        tag_post_list = tag_post_list ++ [post.slug]
        :ets.insert(meta_table, {keyword, tag_post_list})
      end
    end
  end
end
