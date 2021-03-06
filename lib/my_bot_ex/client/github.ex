defmodule MyBotEx.Client.Github do
  use GenServer

  alias Tentacat, as: TC
  alias MyBotEx.Client.Github.PullRequest

  @token Application.get_env :my_bot_ex, :token
  @endpoint Application.get_env :my_bot_ex, :endpoint

  @type auth :: %{access_token: binary}
  @type t :: %Tentacat.Client{auth: auth, endpoint: binary}

  def start_link(default), do: GenServer.start_link __MODULE__, default, [name: __MODULE__]

  def create_client(token \\ []), do: GenServer.call __MODULE__, {:github_client, token}

  @spec client() :: t
  @spec client(:token) :: t
  def client, do: TC.Client.new %{}
  def client(:token), do: TC.Client.new %{access_token: @token}

  @spec c_client :: t
  @spec c_client(:token) :: t
  def c_client, do: TC.Client.new %{}, @endpoint
  def c_client(:token), do: TC.Client.new %{access_token: @token}, @endpoint

  def request do
    header = %{x_github_event: "pull_request"}
    event(header.x_github_event)
  end

  # TODO: use `defprotocol` and `defimp`
  # defp event("commit_comment"), do: CommitComment.action "commit_comment"
  # defp event("fork"), do: Fork.action "fork"
  # defp event("gollum"), do: Gollum.action "gollum"
  # defp event("issue_comment"), do: IssueCmment.action "issue_comment"
  # defp event("issues"), do: Issues.action "issues"
  # defp event("pull_request_review_comment"), do: PullRequestReviewComment.action "pull_request_review_comment"
  defp event("pull_request"), do: PullRequest.action "opened"

  # server

  # receive from `GenServer.call` to __MODULE__
  def handle_call({:github_client, token}, _from, state) do
    case token do
      :token ->
        {:reply, client(:token), state}
      _ ->
        {:reply, client, state}
    end
  end

end
