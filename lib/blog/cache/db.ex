defmodule Blog.Cache.Db do
  import Blog.Cache.Models

  @post_list "post_list"

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
    end
  end
end
