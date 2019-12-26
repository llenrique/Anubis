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

  defstruct name: nil, 
            race: nil, # :pit_bull, :persian, :russian, etc
            pet_type: nil, # :canine, :feline, :rodent
            adoption_date: nil,
            birth_date: nil,
            age_time: nil,
            adoption_type: "", # :of_street, :given, :bought, :born
            age_status: [:puppy, :adult], # if actually is a :puppy or adult
            adoption_age: [:puppy, :adult],
            race_size: [:small, :medium, :large, :giant], # :small, :medium, :large, :giant
            gender: nil,
            alive_status: :alive,
            death_date: nil,
            vaccine_table: %{}
            

  @doc """
  Creates a pet
  """
  @spec create_pet(map) :: Pet
  def create_pet(pet) do
    pet
    |> _cast_date_fields()
    |> _calculate_age_status()
    |> _cast_params_to_struct()
  end

  # Converts a string to Date
  @spec _cast_date_fields(map) :: map
  defp _cast_date_fields(%{adoption_date: adoption_date} = pet) when is_binary (adoption_date) do
    pet
    |> Map.update!(:adoption_date, &Date.from_iso8601!(&1))
    |> _cast_date_fields()
  end

  defp _cast_date_fields(%{birth_date: birth_date} = pet) when is_binary (birth_date) do
    pet
    |> Map.update!(:birth_date, &Date.from_iso8601!(&1))
    |> _cast_date_fields()
  end

  # Case when obtained_date is actually a Date type
  defp _cast_date_fields(pet), do: pet

  # Calculates the age_in_weeks sice adoption_date when adoption_age is :puppy
  @spec _calculate_age_weeks_for_pet(map) :: map
  defp _calculate_age_weeks_for_pet(%{adoption_age: :puppy} = pet) do
    Timex.diff(Date.utc_today(), pet.birth_date, :weeks)
  end

  # Calculates age_status using race_size
  @spec _calculate_age_status(map) :: map
  defp _calculate_age_status(%{adoption_age: :adult} = pet) do
    Map.put(pet, :age_status, :adult)
  end

  defp _calculate_age_status(
    %{
      adoption_age: :puppy, 
      race_size: race_size,
    } = pet) when race_size == :small or race_size == :medium do

    case _calculate_age_weeks_for_pet(pet) do
      weeks when weeks >= 18 -> Map.put(pet, :age_status, :adult)
      _ -> Map.put(pet, :age_status, :puppy)
    end
  end

  defp _calculate_age_status(
    %{
      adoption_age: :puppy, 
      race_size: race_size,
    } = pet) when race_size == :large or race_size == :giant do

    case _calculate_age_weeks_for_pet(pet) do
      weeks when weeks >= 104 -> Map.put(pet, :age_status, :adult)
      _ -> Map.put(pet, :age_status, :puppy)
    end
  end

  # Builds a struct when the given params
  @spec _cast_params_to_struct(map) :: Pet
  defp _cast_params_to_struct(pet) do
    struct(__MODULE__, Map.to_list(pet))
  end

  @doc """
  Update the alive_status for a pet
  """
  @spec update_death_date_for_pet(Pet, String.t()) :: Pet
  def update_death_date_for_pet(pet, death_date) do
    death_date = Date.from_iso8601!(death_date)

    age_time = Timex.diff(death_date, pet.adoption_date, :weeks)

    pet
    |> Map.replace!(:death_date, death_date)
    |> Map.put(:age_time, age_time)
    |> Map.replace!(:alive_status, :death)

  end

end
