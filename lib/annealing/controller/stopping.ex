defmodule Annealing.Controller.Stopping do
  @moduledoc false
  require Logger

  alias Annealing.Material

  @type stop_condition ::
          {:energy_threshold, float()}
          | {:temperature_threshold, float()}
          | {:iteration_limit, pos_integer() | :infinity}
          | {:stagnation_limit, pos_integer() | :infinity}
  @type stop_conditions :: [stop_condition, ...]

  @type annealing_state :: Annealing.Controller.state()

  @spec should_stop?(annealing_state()) :: boolean()
  def should_stop?({iteration, material, regime}) do
    zero = 0.0
    dbg({iteration, material.energy, material.temperature})

    any_stop_condition =
      Enum.any?(regime.stop_conditions, fn stop_condition ->
        case stop_condition do
          {:energy_threshold, threshold} ->
            Logger.debug("stopping, reached energy_threshold: #{threshold}")
            material.energy <= threshold

          {:temperature_threshold, threshold} ->
            Logger.debug("stopping, reached temperature_threshold: #{threshold}")
            material.temperature <= threshold

          {:iteration_limit, :infinity} ->
            false

          {:iteration_limit, limit} when limit >= zero ->
            if iteration >= limit, do: Logger.debug("stopping, reached iteration_limit: #{limit}")
            iteration >= limit

          {:stagnation_limit, :infinity} ->
            false

          {:stagnation_limit, limit} ->
            if reached_stagnation_limit(material, regime, limit),
              do: Logger.debug("stopping, reached stagnation_limit: #{limit}")

            reached_stagnation_limit(material, regime, limit)
        end
      end)

    # TODO: add stop reason to regime struct

    if material.temperature <= zero, do: Logger.debug("stopping, temperature is zero")
    material.temperature <= zero || any_stop_condition
  end

  defp reached_stagnation_limit(material, regime, limit) do
    stagnation_count =
      Enum.count(regime.history, fn history_item ->
        case history_item do
          %Material{energy: energy} -> energy == material.energy
          _ -> false
        end
      end)

    stagnation_count >= limit
  end
end
