defmodule BlogWeb.IndexController do
  use BlogWeb, :controller

  def index(conn, _params) do
    {posts, pages} = Blog.Cache.get_page(1)
    render(conn, "index.html", posts: posts, pages: pages, page: 1, page_atom: :page)
  end

  def page(conn, %{"page" => page}) do
    case Integer.parse(page) do
      {page, ""} ->
        {posts, pages} = Blog.Cache.get_page(page)
        render(conn, "index.html", posts: posts, pages: pages, page: page, page_atom: :page)
      _ ->
        conn |> redirect(to: index_path(conn, :index)) |> halt
    end
  end

  def tag(conn, %{"tag" => tag}) do
    {posts, pages} = Blog.Cache.get_tag_page(tag, 1)
    render(conn, "index.html", posts: posts, pages: pages, page: 1, page_atom: :tag_page, tag: tag)
  end

  def tag_page(conn, %{"tag" => tag, "page" => page}) do
    case Integer.parse(page) do
      {page, ""} ->
        {posts, pages} = Blog.Cache.get_tag_page(tag, page)
        render(conn, "index.html", posts: posts, pages: pages, page: page, page_atom: :tag_page, tag: tag)
      _ ->
        conn |> redirect(to: index_path(conn, :index)) |> halt
    end
  end
end
