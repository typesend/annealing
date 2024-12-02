defmodule Annealing.Regime do
  @moduledoc """
  A struct to hold details about the overall annealing process.
  """
  use TypedStruct

  typedstruct enforce: true do
    field :module, module()
    field :cooling_strategy, Annealing.Controller.Cooling.cooling_strategy()
    field :stop_conditions, Annealing.Controller.Stopping.stop_conditions(), default: []
    field :history, list(Annealing.Material.t() | term()), default: []
    field :identifier, nil | term(), enforce: false

    field :acceptance_fun, fun(),
      default: &Annealing.Controller.Acceptance.metropolis_probability/2
  end

  def iterations(regime) do
    Enum.count(regime.history) + 1
  end
end
