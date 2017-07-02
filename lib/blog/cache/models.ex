defmodule Blog.Cache.Models do
  defmodule Post do
    defstruct slug: nil,
      title: nil,
      file: nil,
      date: nil,
      keywords: [],
      text: nil
  end

  def is_post?(%Post{}), do: true
  def is_post?(_), do: false
end
