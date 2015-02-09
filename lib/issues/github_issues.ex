defmodule GithubIssues do
  @github_url Application.get_env(:issues, :github_url)

  def fetch(user, project) do
    issues_url(user, project)
      |> HTTPoison.get
      |> handle_response
  end

  def issues_url(user, project) do
    "#{@github_url}/repos/#{user}/#{project}/issues"
  end

  def headers do
    [{ "Accept", "application/vnd.github.v3+json" }]
  end

  def handle_response({ :ok, %{ body: body } }) do 
    { :ok, :jsx.decode(body) } 
  end

  def handle_response({ :error, %{ body: body } }) do 
    { :error, :jsx.decode(body) }
  end
end
