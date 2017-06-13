defmodule Blog.Cache.Monitor do
  use ExFSWatch, dirs: ["/home/embik/Ablage/blog"]

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
