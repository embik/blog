defmodule Blog.Helpers do
  def get_url do
    env = Application.get_env(:blog, Blog.Endpoint)
    host = env[:url][:host]
    port = 
      case env[:url][:port] do
        nil -> env[:http][:port]
        x -> x
      end

    case port do
      443 -> "https://" <> host
      80 -> "http://" <> host
      x -> "http://" <> host <> ":" <> Integer.to_string(x)
    end
  end
end
