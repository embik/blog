defmodule Blog.Cache.Models do
  defmodule Post do
    defstruct slug: nil,
      title: nil,
      file: nil,
      date: nil,
      keywords: [],
      text: nil
  end
end
