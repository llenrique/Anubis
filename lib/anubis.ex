defmodule Pet do
  @moduledoc """
  Documentation for Anubis.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Anubis.hello()
      :world

  """

  defstruct name: "", 
            age: 0, 
            race: "", 
            type: "", 
            adopted_date: ""
            

  @doc """
  Creates a pet or return error if the struct is incomplete
  """
  @spec create_pet(map) :: Pet
  def create_pet(params) do
    params
    |> _cast_adopted_date()
    |> _set_pet_age()
    |> _cast_params_to_struct()
  end

  # Converts a string to Date
  @spec _cast_adopted_date(map) :: map
  defp _cast_adopted_date(%{adopted_date: adopted_date} = params) do
    Map.update!(params, :adopted_date, &Date.from_iso8601!(&1))
  end

  # Case when adopted_date is actually a Date type
  defp _cast_adopted_date(params), do: params

  # When age is not provided calculates pet age
  @spec _set_pet_age(map) :: map
  defp _set_pet_age(%{age: age} = params) when is_nil(age) do
    years_since_adopted_date = 
      Timex.diff(Date.utc_today(), params.adopted_date, :months)

    Map.replace!(params, :age, years_since_adopted_date)
  end

  # If age is provided
  defp _set_pet_age(params), do: params

  # Builds a struct when the given params
  @spec _cast_params_to_struct(map) :: Pet
  defp _cast_params_to_struct(params) do
    struct(Pet, Map.to_list(params))
  end
end
