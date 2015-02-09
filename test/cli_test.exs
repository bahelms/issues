defmodule CLITest do
  use ExUnit.Case
  import Issues.CLI, only: [parse_args: 1, 
                            sort_ascending: 1,
                            convert_to_list_of_hash_dicts: 1]

  test ":help returned by option parsing with -h and --help options" do
    assert parse_args(["-h", "anything"]) == :help
    assert parse_args(["--help"]) == :help
  end

  test "three values returned if three given" do
    assert parse_args(["user", "project", "99"]) == { "user", "project", 99 }
  end

  test "count is defaulted if two values given" do
    assert parse_args(["user", "project"]) == { "user", "project", 4 }
  end

  test "sort ascending orders the correct way" do
    results = fake_list(["c", "a", "b"]) |> sort_ascending
    issues = for issue <- results, do: issue["created_at"]
    assert issues == ~w{a b c}
  end

  defp fake_list(values) do
    for value <- values, do: [{ "created_at", value }, { "other_data", "xxx" }]
      |> convert_to_list_of_hash_dicts
  end
end
