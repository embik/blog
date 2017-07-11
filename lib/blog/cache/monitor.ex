defmodule Blog.Cache.Monitor do
  require Logger
  use ExFSWatch, dirs: [Application.get_env(:blog, Blog.Endpoint)[:post_folder]]


  def callback(:stop) do
    IO.puts("STOP")
  end

  def callback(file_path, [:modified]) do
    Logger.debug("Running Blog.Cache.Monitor callback for file modification\n   File: #{file_path}")
    Blog.Cache.reload(file_path)
  end

  def callback(_, _) do
    nil
  end
end
