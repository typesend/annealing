defmodule Annealing.Controller.Cooling do
  @moduledoc "Contains function clauses that cool material state."

  alias Annealing.Material

  @type annealing_state :: Annealing.Controller.state()

  @type cooling_strategy ::
          {:linear, float()}
          | {:exponential, float()}
          | {:logarithmic, float()}
          | {:custom, function()}

  @spec cooldown(annealing_state()) :: annealing_state()

  @doc """
  Allows different cooling strategies to be used:
  linear, exponential, logarithmic, or a custom function.
  """
  def cooldown({iteration, material, regime} = state) do
    new_temp =
      case new_temperature(state) do
        temp when temp <= 0.0 -> 0.0
        temp -> temp
      end

    {iteration, %Material{material | temperature: new_temp}, regime}
  end

  @spec new_temperature(annealing_state()) :: float()
  defp new_temperature({iteration, material, regime}) do
    case regime.cooling_strategy do
      {:linear, rate} ->
        material.temperature - rate

      {:exponential, rate} ->
        material.temperature * (1 - rate)

      {:logarithmic, rate} ->
        # dbg(%{rate: rate, temperature: material.temperature, math_log: :math.log(iteration + 1)})
        rate * material.temperature / :math.log(iteration + 1)

      {:custom, fun} when is_function(fun, 1) ->
        fun.({iteration, material, regime})

      _ ->
        raise "Invalid cooling strategy: #{inspect(regime.cooling_strategy)}"
    end
  end
end
