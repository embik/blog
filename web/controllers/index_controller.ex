defmodule Blog.IndexController do
  use Blog.Web, :controller

  def index(conn, _params) do
    {posts, pages} = Blog.Cache.fetch_page(1)
    render(conn, "index.html", posts: posts, pages: pages, page: 1)
  end

  def page(conn, %{"page" => page}) do
    case Integer.parse(page) do
      {page, ""} ->
        {posts, pages} = Blog.Cache.fetch_page(page)
        render(conn, "index.html", posts: posts, pages: pages, page: page)
      _ ->
        conn |> redirect(to: index_path(conn, :index)) |> halt
    end
  end

  def tag(conn, %{"tag" => tag}) do

  end
end
