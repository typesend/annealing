defmodule Annealing do
  @external_resource "annealing.md"
  @moduledoc File.read!("lib/annealing.md")

  alias Annealing.{Controller, Material, Regime}

  @type items :: Annealing.Material.item_list()

  @type state :: Annealing.Controller.state()

  @callback generate_neighbor(items()) :: items()

  @callback calculate_energy(items()) :: float()

  @type run_option ::
          {:identifier, term()}
          | {:stop_conditions, Controller.Stopping.stop_conditions()}
          | {:temperature, float()}
          | {:cooling_strategy, Controller.Cooling.cooling_strategy()}
  @type run_options :: [run_option]

  @spec run(module(), items(), run_options()) ::
          {:ok, items(), state()} | {:error, term(), state()}

  def run(implementation, items, opts \\ []) do
    unless implements?({implementation, :calculate_energy, 1}),
      do: raise(ArgumentError, "#{implementation} does not implement calculate_energy/1")

    unless implements?({implementation, :generate_neighbor, 1}),
      do: raise(ArgumentError, "#{implementation} does not implement generate_neighbor/1")

    material = %Material{
      items: items,
      temperature: Keyword.get(opts, :temperature, default_options()[:temperature]),
      energy: implementation.calculate_energy(items)
    }

    regime = %Regime{
      module: implementation,
      cooling_strategy:
        Keyword.get(opts, :cooling_strategy, default_options()[:cooling_strategy]),
      stop_conditions: Keyword.get(opts, :stop_conditions, default_options()[:stop_conditions]),
      history: [],
      identifier: Keyword.get(opts, :identifier, nil)
    }

    Controller.perform_annealing({0, material, regime})
  end

  # Loads default options from your Application Config or uses the default values here.
  defp default_options do
    Application.get_env(:annealing, :defaults,
      stop_conditions: [iteration_limit: 2500],
      temperature: 200.0,
      cooling_strategy: {:linear, 0.23}
    )
  end

  @spec implements?(mfa()) :: boolean()
  defp implements?({module, function, arity}) do
    Code.ensure_loaded?(module) && function_exported?(module, function, arity)
  end
end
