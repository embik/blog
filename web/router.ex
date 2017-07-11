defmodule Blog.Router do
  use Blog.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Blog.Plug.Locale, "en"
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Blog do
    pipe_through :browser # Use the default browser stack

    get "/", IndexController, :index
    get "/imprint", PageController, :imprint
    get "/foss-licenses", PageController, :licenses
    get "/:slug", PostController, :post
    get "/page/:page", IndexController, :page
    get "/tag/:tag", IndexController, :tag
    get "/tag/:tag/page/:page", IndexController, :tag_page
  end
end
