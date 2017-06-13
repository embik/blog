defmodule Blog.IndexController do
  use Blog.Web, :controller

  def index(conn, _params) do
    posts = Blog.Cache.fetch_index()
    render(conn, "index.html", posts: posts)
  end
end
