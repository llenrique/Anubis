defmodule Anubis.Pet do
  @moduledoc """
  Abubis is the library for managing pets information. The intention of this
  module is to create a pet with the information given y the owner like name,
  adoption_age, adoption_date and if it's possible, the birth_date.

  This module actually can create a basic structure for a pet, calculate the age in weeks for the pet since the bith_date, determinate if the pet si an
  adult or a puppy, and in the worst case you can set your pet as death passing 
  the death_date to the update_death_date_for_pet.

  This module can actually determinate if a puppy can be set in adoption if the
  weeks sicne birth_date is greater than 12. Otherwise the puppy cannot be set
  in adoption. For adult pets not age validation is required.
  """

  alias __MODULE__

  defstruct name: nil, 
            race: nil, # :pit_bull, :persian, :russian, etc
            pet_type: nil, # :canine, :feline, :rodent
            adoption_date: nil,
            birth_date: nil,
            age_time: nil,
            adoption_type: "", # :of_street, :given, :bought, :born
            age_status: nil, # if actually is a :puppy or adult
            adoption_age: nil,
            adoption_status: false,
            race_size: nil, # :small, :medium, :large, :giant
            gender: nil,
            alive_status: :alive,
            death_date: nil,
            vaccine_table: %{}


  @adult_for_big_dogs 104
  @adult_for_small_dogs 78
  @weeks_to_put_in_adoption 12
            

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
  defp _cast_date_fields(
    %{
      adoption_date: adoption_date
    } = pet) when is_binary (adoption_date) do
    pet
    |> Map.update!(:adoption_date, &Date.from_iso8601!(&1))
    |> _cast_date_fields()
  end

  defp _cast_date_fields(
    %{
      birth_date: birth_date
    } = pet) when is_binary (birth_date) do
    pet
    |> Map.update!(:birth_date, &Date.from_iso8601!(&1))
    |> _cast_date_fields()
  end

  # Case when date fields are actually a Date type
  defp _cast_date_fields(pet), do: pet

  # Calculates the age_in_weeks sice birth_date when adoption_age is :puppy
  @spec _calculate_age_weeks_for_pet(map) :: map
  defp _calculate_age_weeks_for_pet(
    %{
      birth_date: nil
    } = pet) do
    "Age must be calculated fot a vet"
  end
  
  defp _calculate_age_weeks_for_pet(
    %{
      birth_date: _,
      adoption_age: :puppy
    } = pet) do
    Timex.diff(Date.utc_today(), pet.birth_date, :weeks)
  end

  # Calculates age_status using race_size
  #   The :adult age is different for 
  #   large and giant (104 weeks) races from small
  #   and medium (78 weeks)
  #   
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
      weeks when weeks >= @adult_for_small_dogs -> 
        Map.put(pet, :age_status, :adult)
      _ -> 
        Map.put(pet, :age_status, :puppy)
    end
  end

  defp _calculate_age_status(
    %{
      adoption_age: :puppy, 
      race_size: race_size,
    } = pet) when race_size == :large or race_size == :giant do

    case _calculate_age_weeks_for_pet(pet) do
      weeks when weeks >= @adult_for_big_dogs -> 
        Map.put(pet, :age_status, :adult)
      _ -> 
        Map.put(pet, :age_status, :puppy)
    end
  end

  # Builds a struct whith the given params
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

  @doc """
  If a person wants to give in adoption a pet, this function will update
  the adoption status
  """
  @spec update_adoption_status_for_pet(Pet, atom) :: Pet | map
  def update_adoption_status_for_pet(
    %{
      adoption_age: :puppy
    } = pet, 
    adoption_status) do
    
    with {:ok, _} <- _check_for_set_in_adoption_availability(pet) do
      Map.replace!(pet, :adoption_status, adoption_status)
    else
      {:error, reason} ->
        IO.inspect(reason, label: "Error")
        {:error, reason}
    end
  end
  
  def update_adoption_status_for_pet(
    %{
      adoption_age: :adult
    } = pet, 
    adoption_status) do
    
    Map.replace!(pet, :adoption_status, adoption_status)
  end

  defp _check_for_set_in_adoption_availability(pet) do
    case _calculate_age_weeks_for_pet(pet) do
      weeks when weeks > @weeks_to_put_in_adoption -> 
        {:ok, "This pet can be put in adoption"}
      _ -> 
        {:error, "Puppies can be put in adoption 12 weeks afer born"}
    end
  end

end
