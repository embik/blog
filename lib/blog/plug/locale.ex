defmodule Blog.Plug.Locale do
  import Plug.Conn

  def init(default), do: default

  def call(conn, default) do
    locales = extract_accept_language(conn)
    supported = Application.get_env(:blog, Blog.Endpoint)[:supported_locales]
    locale = get_supported_locale(locales, supported, default)
    conn |> assign_locale!(locale)
  end

  defp get_supported_locale([], _supported, default), do: default
  defp get_supported_locale([head | tail], supported, default) do
    if head in supported || head == default do
      head
    else
      get_supported_locale(tail, supported, default)
    end
  end

  defp extract_accept_language(conn) do
    case get_req_header(conn, "accept-language") do
      [value | _] ->
        value
        |> String.split(",")
        |> Enum.map(&parse_language_option/1)
        |> Enum.sort(&(&1.quality > &2.quality))
        |> Enum.map(&(&1.tag))
      _ -> []
    end
  end

  defp parse_language_option(string) do
    captures = ~r/^\s?(?<tag>[\w\-]+)(?:;q=(?<quality>[\d\.]+))?$/i |> Regex.named_captures(string)
    tag = String.replace(captures["tag"], "-", "_")
    quality = case Float.parse(captures["quality"] || "1.0") do
      {val, _} -> val
      _ -> 1.0
    end

    %{tag: tag, quality: quality}
  end

  defp assign_locale!(conn, value) do
    Gettext.put_locale(Blog.Gettext, value)
    conn |> assign(:locale, value)
  end
end
