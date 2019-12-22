defmodule Anubis.Pet do
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
            race: "", # :pit_bull, :persian, :russian, etc
            pet_type: "", # :canine, :feline, :rodent
            obtained_date: "", 
            adoption_type: "", # :of_street, :given, :bought
            age_status: [:puppy, :adult], # if actually is a :puppy or adult
            adoption_age: [:puppy, :adult],
            age_time: nil, # number of mmonths
            size: [:small, :medium, :large, :giant] # :small, :medium, :large, :giant
            

  @doc """
  Creates a pet
  """
  @spec create_pet(map) :: Pet
  def create_pet(params) do
    params
    |> _cast_obtained_date()
    |> _calculate_age_time()
    |> _calculate_age_status()
    |> _cast_params_to_struct()
  end

  # Converts a string to Date
  @spec _cast_obtained_date(map) :: map
  defp _cast_obtained_date(%{obtained_date: _obtained_date} = params) do
    Map.update!(params, :obtained_date, &Date.from_iso8601!(&1))
  end

  # Case when obtained_date is actually a Date type
  defp _cast_obtained_date(params), do: params

  # Calculates the age_time sice adoption_date when adoption_age is :puppy
  @spec _calculate_age_time(map) :: map
  defp _calculate_age_time(%{adoption_age: :puppy} = params) do
    age_time = Timex.diff(Date.utc_today(), params.obtained_date, :months)

    Map.put(params, :age_time, age_time)
  end

  # Calculates the age_time since adoption_date when adoption_age is :adult
  @spec _calculate_age_time(map) :: map
  defp _calculate_age_time(%{adoption_age: :adult} = params) do
    Map.put(params, :age_time, "Must be calculated for a vet")
  end

  # Calculates age_status using the age_time, adoption_age, and size
  @spec _calculate_age_status(map) :: map
  defp _calculate_age_status(%{adoption_age: :adult} = params) do
    Map.put(params, :age_status, :adult)
  end

  defp _calculate_age_status(
    %{
      adoption_age: :puppy,
      size: size
    } = params) when size == :large or size == :giant do
    age_status = if params.age_time < 24 do
      :puppy
    else
      :adult
    end
    Map.put(params, :age_status, age_status)
  end

  defp _calculate_age_status(
    %{
      adoption_age: :puppy,
      size: size
    } = params) when size == :small or size == :medium do
    age_status = if params.age_time < 18 do
      :puppy
    else
      :adult
    end
    Map.put(params, :age_status, age_status)
  end

  # Builds a struct when the given params
  @spec _cast_params_to_struct(map) :: Pet
  defp _cast_params_to_struct(params) do
    struct(Pet, Map.to_list(params))
  end
end
