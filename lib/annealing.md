  A generic implementation of the Simulated Annealing optimization algorithm.

  Simulated Annealing is a probabilistic technique for approximating the global optimum
  of a given function. It is often used to solve combinatorial optimization problems
  like the Traveling Salesman Problem, job scheduling, or circuit design.

  ## Strategy Behaviour

  To use this module, you must implement a strategy module that defines the problem-specific
  parts of the algorithm. The strategy module must implement the following callbacks:

    * `init/2` - Initialize the solution state
    * `calculate_energy/1` - Calculate the "energy" (cost) of a solution
    * `get_neighbor/1` - Generate a neighboring solution

  ## Example

      defmodule TravelingSalesmanStrategy do
        @behaviour Annealing

        @impl true
        def init(cities, _opts), do: {:ok, cities}

        @impl true
        def calculate_energy(route) do
          route
          |> Enum.chunk_every(2, 1, :wrap)
          |> Enum.map(fn [{x1, y1}, {x2, y2}] ->
            :math.sqrt(:math.pow(x2 - x1, 2) + :math.pow(y2 - y1, 2))
          end)
          |> Enum.sum()
        end

        @impl true
        def get_neighbor(route) do
          i = :rand.uniform(length(route)) - 1
          j = :rand.uniform(length(route)) - 1

          List.replace_at(
            List.replace_at(route, i, Enum.at(route, j)),
            j,
            Enum.at(route, i)
          )
        end
      end

      # Using the strategy
      cities = [{0, 0}, {1, 5}, {2, 2}, {3, 3}]
      {:ok, optimal_route} = Annealing.run(TravelingSalesmanStrategy, cities)

  ## Configuration Options

  The following options can be passed to `run/3`:

    * `:temperature` - Initial temperature (default: 100.0)
    * `:cooldown` - Cooling rate per iteration (default: 0.004)
    * `:break_energy` - Target energy level to stop at (default: 0.0)
    * `:max_iterations` - Maximum number of iterations (default: :infinity)
    * `:name` - Optional name for the annealing process (default: nil)

  ## Algorithm Details

  The algorithm works by iteratively:
  1. Generating a neighbor solution
  2. Calculating the energy difference (ΔE) between current and neighbor
  3. Accepting the neighbor if it's better (ΔE < 0)
  4. Accepting worse solutions with probability P(ΔE) = e^(-ΔE/T)
  5. Decreasing temperature according to the cooling schedule

  The temperature starts high (accepting many worse solutions) and gradually
  decreases, causing the algorithm to become more selective over time. This
  combination of exploration and exploitation helps escape local optima.
