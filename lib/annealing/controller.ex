defmodule Annealing.Controller do
  @moduledoc """
  Controls execution of simulated annealing.
  """
  alias Annealing.{Material, Regime}

  import __MODULE__.Cooling, only: [cooldown: 1]
  import __MODULE__.Stopping, only: [should_stop?: 1]
  import __MODULE__.Acceptance, only: [choose_best_material: 2]

  @type state :: {iteration_number(), Material.t(), Regime.t()}
  @type iteration_number :: integer()

  @type items :: Annealing.Material.item_list()

  @spec perform_annealing(state()) :: {:ok, items(), state()} | {:error, term(), state()}

  def perform_annealing({_iteration, _material, _regime} = prior_state) do
    new_state =
      prior_state
      |> increment_iteration()
      |> mutate_material()
      |> cooldown()
      |> choose_best_material(prior_state)
      |> record_history()

    if should_stop?(new_state),
      do: finish_annealing(new_state),
      else: perform_annealing(new_state)
  end

  @spec finish_annealing(state()) :: {:ok, items(), state()}
  def finish_annealing({iteration, material, regime}) do
    {:ok, material.items, {iteration, material, %Regime{regime | history: tl(regime.history)}}}
  end

  @spec increment_iteration(state()) :: state()
  defp increment_iteration({iteration, material, regime}) do
    {iteration + 1, material, regime}
  end

  @spec mutate_material(state()) :: state()
  defp mutate_material({iteration, material, regime}) do
    updated_items = apply(regime.module, :generate_neighbor, [material.items])

    updated_material = %Material{
      material
      | items: updated_items,
        energy: apply(regime.module, :calculate_energy, [updated_items])
    }

    {iteration, updated_material, regime}
  end

  @spec record_history(state()) :: state()
  defp record_history({iteration, material, regime}) do
    updated_regime = %Regime{regime | history: [material | regime.history]}
    {iteration, material, updated_regime}
  end
end

# @spec call_if_implemented({module(), atom(), list()}, term()) :: term()
# defp call_if_implemented({module, function, args}, default) do
#   if implements?({module, function, length(args)}) do
#     apply(module, function, args)
#   else
#     default
#   end
# end
