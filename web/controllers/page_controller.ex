defmodule Blog.PageController do
  use Blog.Web, :controller

  def imprint(conn, _params) do
    conn
    |> assign(:title, "Imprint")
    |> render("imprint.html")
  end

  def licenses(conn, _params) do
    conn
    |> assign(:title, "Lizenzen")
    |> render("licenses.html")
  end
end
