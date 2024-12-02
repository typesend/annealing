defmodule Annealing.Material do
  @moduledoc """
  A struct to hold the volatile state of each step of the annealing algorithm.
  """
  use TypedStruct

  @type item_list :: list()

  typedstruct enforce: true do
    field :temperature, float()
    field :items, item_list()
    field :energy, float()
  end
end
