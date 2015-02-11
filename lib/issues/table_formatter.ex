defmodule Issues.TableFormatter do
  def display_table(rows, headers) do
    columns = split_into_columns(rows, headers)
    widths = widths_of(columns)
    format = format_for(widths)

    display_one_row(headers, format)
    display_header_seperator(widths)
    display_columns(columns, format)
  end

  def split_into_columns(rows, headers) do
    for header <- headers do
      for row <- rows, do: printable(row[header])
    end
  end

  def printable(str) when is_binary(str), do: str
  def printable(str), do: to_string(str)

  def widths_of(columns) do
    for column <- columns, do: Enum.map(column, &String.length/1) |> Enum.max
  end

  @doc """
  Return a format string that hard codes the widths of a set of columns. 
  We put `" | "` between each column.

  ## Example
  
      iex> widths = [5,6,99]
      iex> Issues.TableFormatter.format_for(widths)
      "~-5s | ~-6s | ~-99s~n"

  """
  def format_for(widths) do
    Enum.map_join(widths, " | ", fn width -> "~-#{width}s" end) <> "~n"
  end

  def display_one_row(row, format) do
    :io.format(format, row)
  end

  def display_header_seperator(widths) do
    Enum.map_join(widths, "-+-", fn width -> List.duplicate("-", width) end)
      |> IO.puts
  end

  def display_columns(columns, format) do
    columns
      |> List.zip
      |> Enum.map(&Tuple.to_list/1)
      |> Enum.each(&display_one_row(&1, format))
  end
end

