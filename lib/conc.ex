defmodule Conc do
  @moduledoc """
  Module that provides common functional programming functions in a concurrent (and possibly paralllel) form. This is acheived mostly using Task API from the standard library.
  """

  @spec map([any], fun) :: [any]
  @doc """
  Perform a function on each element of an enumerable and return a new enumerable with the results

  ## Examples

      iex> Conc.map([1,2,3], fn x -> x + x end)
      [2,4,6]

  """
  def map(list, func) do
    list
    |> Enum.map(fn x -> Task.async(fn -> func.(x) end) end)
    |> Enum.map(&Task.await/1)
  end
  @spec filter([any], fun) :: [any]
  @doc """
  Filter out elements from an enumerable. Returns a new enumerable without the elements that do not return true from the passed function.

  ## Examples

      iex> Conc.filter([1,2,3], fn x -> x < 3 end)
      [1,2]

  """
  def filter(list, func) do
    list
    |> map(func)
    |> filter_bool(list)
  end

  @spec filter_bool([boolean()], [any]) :: [any]
  @doc """
  Filter a list based on a list of bools.

  ## Example

    iex> Conc.filter_bool([true,true,false],[1,2,3])
    [1,2]

  """
  def filter_bool(bool_list, list) do
    filter_bool_lis(bool_list, list, [])
  end

  defp filter_bool_lis(bool_lis, list, new_lis) do
    case list do
      [] -> Enum.reverse(new_lis)
      _ ->
        [bhead|btail] = bool_lis
        [lhead|ltail] = list
        cond do
          bhead == false -> filter_bool_lis(btail, ltail, new_lis)
          bhead == true -> filter_bool_lis(btail, ltail, [lhead|new_lis])
        end
    end
  end

  @spec all?([any], fun) :: boolean()
  @doc """
  Returns true if all of the elements of an enumerable return true from the function passed.

  ## Example

    iex>Conc.all?([4,4,4],fn x -> x > 2 end)
    true

    iex>Conc.all?([1,4,4], fn x -> x > 2 end)
    false

  """
  def all?(list, func) do
    list
    |> map(func)
    |> all_true()
  end

  defp all_true(bool_list) do
    case bool_list do
      [true] -> true
      [false] -> false
      _ ->
        [head|tail] = bool_list
        cond do
          head == false -> false
          head == true -> all_true(tail)
        end
    end
  end

  @spec any?([any], fun) :: boolean()
  @doc """
  Returns true if any of the elements of an enumerable return true from the passed function.

  ## Example

    iex>Conc.any?([4,4,1], fn x -> x < 4 end)
    true

    iex>Conc.any?([1,1,1], fn x -> x > 2 end)
    false

  """
  def any?(list, func) do
    list
    |> map(func)
    |> any_true()
  end

  defp any_true(bool_list) do
    case bool_list do
      [false] -> false
      [true] -> true
      _ ->
        [head|tail] = bool_list
        cond do
          head == true -> true
          head == false -> any_true(tail)
        end
    end
  end
end



