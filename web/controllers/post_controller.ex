defmodule Blog.PostController do
  use Blog.Web, :controller

  @validator ~r/^[a-z-0-9]+$/i

  plug :check_slug

  def post(conn, %{"slug" => slug}) do
    lowercase_slug = String.downcase(slug)
    if lowercase_slug != slug do
      conn |> redirect(to: post_path(conn, :post, lowercase_slug)) |> halt
    end

    case Blog.Cache.fetch(slug) do
      post when is_map(post) ->
        render(conn, post: post, title: post.title <> ": " <> post.subtitle)
      nil ->
        conn |> redirect(to: index_path(conn, :index)) |> halt
    end
  end

  defp check_slug(conn, _) do
    case Regex.match?(@validator, conn.params["slug"]) do
      false ->
        conn |> redirect(to: index_path(conn, :index)) |> halt
      true ->
        conn
    end
  end
end
