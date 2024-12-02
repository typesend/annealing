defmodule Annealing.Controller.Acceptance do
  @moduledoc "Contains function clauses that determine solution acceptance."

  @type annealing_state :: Annealing.Controller.state()
  @type material :: Annealing.Material.t()

  @spec choose_best_material(annealing_state(), annealing_state()) :: annealing_state()
  def choose_best_material({iteration, current_material, regime} = current_state, prior_state) do
    case should_accept?(current_state, prior_state) do
      true ->
        {iteration, current_material, regime}

      false ->
        {_, prior_material, _} = prior_state
        {iteration, prior_material, regime}
    end
  end

  @doc "Acceptance probability calculting using Metropolis criteria"
  @spec should_accept?(annealing_state(), annealing_state()) :: boolean

  def metropolis_probability(
        {_, current_material, _},
        {_, prior_material, _}
      ) do
    energy_delta =
      current_material.energy - prior_material.energy

    cond do
      energy_delta <= 0 -> true
      current_material.temperature <= 0 -> false
      true -> :rand.uniform() < :math.exp(-energy_delta / current_material.temperature)
    end
  end

  @spec should_accept?(annealing_state(), annealing_state()) :: boolean
  def should_accept?({_, _, regime} = current_state, prior_state) do
    regime.acceptance_fun.(current_state, prior_state)
  end
end
