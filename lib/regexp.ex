defmodule Regexp do
  def start(string) do
    string
    |> String.graphemes
    |> join_special_signs([])
    |> convert_to_struct(0, %{})
    |> struct_to_att
  end

  def convert_to_struct([], current_state, transitions) do
    {:ok, transitions, current_state}
  end
  def convert_to_struct([head | ["+" | tail]], current_state, transitions) do
    transitions =
      transitions
      |> Map.put({current_state, head}, current_state + 1)
    convert_to_struct([head, "*" | tail], current_state + 1, transitions)
  end
  def convert_to_struct([head | ["*" | [tail_head | tail]]], current_state, transitions) do
    transitions =
      transitions
      |> Map.put({current_state, head}, current_state)
      |> Map.put({current_state, tail_head}, current_state + 1)
    convert_to_struct([tail_head | tail], current_state + 1, transitions)
  end
  def convert_to_struct([head | tail], current_state, transitions) do
    transitions =
      transitions
      |> Map.put({current_state, head}, current_state)
      convert_to_struct(tail, current_state, transitions)
  end
  def convert_to_struct([head | tail], current_state, transitions) do
    transitions =
      transitions
      |> Map.put({current_state, head}, current_state + 1)
    convert_to_struct(tail, current_state + 1, transitions)
  end

  def join_special_signs([], list), do: Enum.reverse(list)
  def join_special_signs([head | [tail_head | tail]], list) do
    cond do
      tail_head =~ ~r/[\*\+\?]/ ->
        list = ["#{head}#{tail_head}" | list]
        join_special_signs(tail, list)
      true ->
        list = [head | list]
        join_special_signs([tail_head | tail], list)
    end
  end
  def join_special_signs([head | tail], list) do
    join_special_signs(tail, [head | list])
  end

  @doc """
    Joins transitions map & accepted value into an AT&T string

  ## Examples

      iex> tuple = {:ok, %{{0, "a"} => 1, {1, "b"} => 2, {2, "c"} => 3}, 3}
      iex> Regexp.struct_to_att tuple
      "0 1 a \n1 2 b \n2 3 c\n3"
  """
  def struct_to_att({:ok, transitions, accepted}) do
    # IO.inspect transitions
    transitions =
      transitions
      |> Enum.map(fn {{s1, char}, s2} -> "#{s1} #{s2} #{char}" end)
      |> Enum.join(" \n")

    transitions = transitions <> "\n#{accepted}"
    IO.puts transitions
  end
end
