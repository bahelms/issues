defmodule Issues.GithubIssues do
  require Logger

  # Sets attribute at compile time
  @github_url Application.get_env(:issues, :github_url)

  def fetch(user, project) do
    Logger.info "Fetching user #{user}'s project #{project}"
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
    Logger.info "Successful response"
    Logger.debug fn -> inspect(body) end #lazy eval
    { :ok, :jsx.decode(body) } 
  end

  def handle_response({ :error, %{ status: status, body: body } }) do 
    Logger.error "Error #{status} returned"
    { :error, :jsx.decode(body) }
  end
end
