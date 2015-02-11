defmodule Issues.CLI do
  import Issues.TableFormatter, only: [display_table: 2]

  @default_count 4

  @moduledoc """
  Handle the command line parsing and the dispatch to the various functions 
  that end up generating a table of the last _n_ issues in a github project
  """

  @doc """
  Can run a function with mix: 
  mix main -e 'Issues.CLI.run(["-h"])'
  """
  def main(argv) do
    #Escript looks for a main function and passes char lists as command line args
    argv |> parse_args |> process
  end

  @doc """
  `argv` can be -h or --help, which returns :help.
  Otherwise it is a github user name, project name, and (optionally)
  the number of entries to format.

  Return a tuple of `{ user, project, count }`, or `:help` if help was given.
  """
  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [help: :boolean], aliases: [h: :help])

    case parse do
      { [help: true], _, _ }           -> :help
      { _, [user, project, count], _ } -> { user, project, String.to_integer(count) }
      { _, [user, project], _ }        -> { user, project, @default_count }
      _                                -> :help
    end
  end

  def process(:help) do
    IO.puts "usage: issues <user> <project> [ count | #{@default_count} ]"
    System.halt(0)
  end

  def process({ user, project, count }) do
    Issues.GithubIssues.fetch(user, project) 
      |> decode_response
      |> convert_to_list_of_hash_dicts
      |> sort_ascending
      |> Enum.take(count)
      |> display_table(["number", "created_at", "title"])
  end

  def decode_response({ :ok, body }), do: body
  def decode_response({ :error, body }) do
    { _, message } = List.keyfind(body, "message", 0)
    IO.puts "Error fetching from GitHub: #{message}"
    System.halt(2)
  end

  def convert_to_list_of_hash_dicts(issues) do
    Enum.map(issues, &Enum.into(&1, HashDict.new))
  end

  def sort_ascending(issues) do
    Enum.sort(issues, fn a, b -> a["created_at"] <= b["created_at"] end)
  end
end

