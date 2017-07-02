defmodule Blog.Cache.Monitor do
  use ExFSWatch, dirs: [Application.get_env(:blog, Blog.Endpoint)[:post_folder]]

  def callback(:stop) do
    IO.puts("STOP")
  end

  def callback(file_path, [:modified]) do
    IO.inspect {file_path, [:modified]}
    Blog.Cache.update(file_path)
  end

  def callback(_, _) do
    nil
  end
end
