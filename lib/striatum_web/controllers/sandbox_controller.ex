defmodule StriatumWeb.SandboxController do
  use StriatumWeb, :controller

  alias Striatum.{Repo, SandboxScenario}
  import Ecto.Query

  @scenarios [:sii_timeout, :acquirer_decline, :partial_outage, :webhook_delay, :reset]

  @doc "GET /v1/sandbox/scenarios"
  def index(conn, _params) do
    org_id = conn.assigns[:org_id]
    now = DateTime.utc_now()

    active =
      from(s in SandboxScenario,
        where: s.organization_id == ^org_id,
        where: is_nil(s.expires_at) or s.expires_at > ^now,
        where: s.remaining_count > 0 or is_nil(s.remaining_count)
      )
      |> Repo.all()

    json(conn, %{
      scenarios:
        Enum.map(active, fn s ->
          %{
            id: s.id,
            scenario: s.scenario,
            remaining_count: s.remaining_count,
            expires_at: s.expires_at
          }
        end)
    })
  end

  @doc "POST /v1/sandbox/simulate"
  def simulate(conn, params) do
    org_id = conn.assigns[:org_id]
    scenario_name = params["scenario"]

    scenario_atom =
      try do
        String.to_existing_atom(scenario_name)
      rescue
        ArgumentError -> nil
      end

    cond do
      scenario_name == "reset" ->
        # Clear all active scenarios
        from(s in SandboxScenario, where: s.organization_id == ^org_id)
        |> Repo.delete_all()

        json(conn, %{message: "All sandbox scenarios cleared"})

      scenario_atom in @scenarios && scenario_atom != :reset ->
        # Remove existing scenario of same type
        from(s in SandboxScenario,
          where: s.organization_id == ^org_id,
          where: s.scenario == ^scenario_atom
        )
        |> Repo.delete_all()

        %SandboxScenario{}
        |> SandboxScenario.changeset(%{
          organization_id: org_id,
          scenario: scenario_atom,
          remaining_count: 5,
          expires_at: DateTime.add(DateTime.utc_now(), 600, :second)
        })
        |> Repo.insert!()

        json(conn, %{
          scenario: scenario_name,
          remaining_count: 5,
          expires_at: DateTime.add(DateTime.utc_now(), 600, :second),
          message: "Scenario '#{scenario_name}' active for next 5 transactions (~10 min)"
        })

      true ->
        conn
        |> put_status(422)
        |> json(%{
          error: %{
            code: "invalid_scenario",
            message:
              "Unknown scenario '#{scenario_name}'. Available: #{Enum.join(@scenarios, ", ")}"
          }
        })
    end
  end
end
