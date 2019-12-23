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
  alias __MODULE__

  defstruct name: "", 
            race: "", # :pit_bull, :persian, :russian, etc
            pet_type: "", # :canine, :feline, :rodent
            obtained_date: "", 
            adoption_type: "", # :of_street, :given, :bought
            age_status: [:puppy, :adult], # if actually is a :puppy or adult
            adoption_age: [:puppy, :adult],
            age_time_in_months: nil, # number of mmonths
            size: [:small, :medium, :large, :giant], # :small, :medium, :large, :giant
            gender: nil,
            alive_status: :alive,
            death_date: nil,
            vaccine_table: %{}
            

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
  defp _cast_obtained_date(%{obtained_date: obtained_date} = params) when is_binary (obtained_date) do
    Map.update!(params, :obtained_date, &Date.from_iso8601!(&1))
  end

  # Case when obtained_date is actually a Date type
  defp _cast_obtained_date(params), do: params

  # Calculates the age_time sice adoption_date when adoption_age is :puppy
  @spec _calculate_age_time(map) :: map
  defp _calculate_age_time(%{adoption_age: :puppy} = params) do
    age_time = Timex.diff(Date.utc_today(), params.obtained_date, :months)

    Map.put(params, :age_time_in_months, age_time)
  end

  # Calculates the age_time since adoption_date when adoption_age is :adult
  @spec _calculate_age_time(map) :: map
  defp _calculate_age_time(%{adoption_age: :adult} = params) do
    Map.put(params, :age_time_in_months, "Must be calculated for a vet")
  end

  # Calculates age_status using the age_time, and size
  @spec _calculate_age_status(map) :: map
  defp _calculate_age_status(%{adoption_age: :adult} = params) do
    Map.put(params, :age_status, :adult)
  end

  defp _calculate_age_status(
    %{
      adoption_age: :puppy,
      size: size
    } = params) when size == :large or size == :giant do
    age_status = if params.age_time_in_months < 24 do
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
    age_status = if params.age_time_in_months < 18 do
      :puppy
    else
      :adult
    end
    Map.put(params, :age_status, age_status)
  end

  # Builds a struct when the given params
  @spec _cast_params_to_struct(map) :: Pet
  defp _cast_params_to_struct(params) do
    struct(__MODULE__, Map.to_list(params))
  end

  @doc """
  Update the alive_status for a pet
  """
  @spec update_death_date_for_pet(Pet, String.t()) :: Pet
  def update_death_date_for_pet(pet, death_date) do
    death_date = Date.from_iso8601!(death_date)

    age_time_in_months = Timex.diff(death_date, pet.obtained_date, :months)

    pet
    |> Map.replace!(:death_date, death_date)
    |> Map.replace!(:alive_status, :death)
    |> Map.replace!(:age_time_in_months, age_time_in_months)


  end

end
