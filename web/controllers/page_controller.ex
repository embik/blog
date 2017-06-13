defmodule Blog.PageController do
  use Blog.Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def imprint(conn, _params) do
    render(conn, "imprint.html")
  end

  def licenses(conn, _params) do
    render(conn, "licenses.html")
  end
end
