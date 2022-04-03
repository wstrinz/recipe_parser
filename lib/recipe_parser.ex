defmodule RecipeParser do
  import Meeseeks.CSS
  import Meeseeks.XPath

  @moduledoc """
  Documentation for `RecipeParser`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> RecipeParser.hello()
      :world

  """
  def extract_recipes(file) do
    document = File.read!(file) |> Meeseeks.parse()

    IO.puts("Collecting titles")

    recipe_titles = Meeseeks.all(document, css("h1"))

    IO.puts("Chunking Recipes")

    recipe_titles
    |> Enum.with_index(1)
    |> Enum.map(fn {title, idx} ->
      Task.async(fn ->
        content =
          Meeseeks.all(
            document,
            xpath("//*/*[not(self::h1) and count(preceding-sibling::h1)=#{idx}]")
          )

        IO.puts("Processed ##{idx}")

        %{title: title, content: content}
      end)
    end)
    |> Task.await_many(:infinity)
  end

  def write_output_html(recipes) do
    recipes
    |> Enum.map(fn %{title: title, content: content} ->
      content_string =
        content
        |> Enum.map(&Meeseeks.html/1)
        |> Enum.join("\n")

      title_string = Meeseeks.text(title)

      file_title = title_string |> String.downcase() |> String.replace(" ", "_")

      IO.puts("Writing #{file_title}")

      text = """
      <!DOCTYPE html>
      <html>
        <head>
          <title>#{title_string}</title>
        </head>
        <body>
          #{content_string}
        </body>
      </html>
      """

      File.write!("html_conversion/#{file_title}.html", text)
    end)
  end

  def run do
    extract_recipes("html_conversion/recipes_full/recipes.html")
    |> write_output_html()
  end
end
