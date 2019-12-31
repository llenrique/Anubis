defmodule Anubis.Pet do
  
  defstruct name: nil,
            species: nil,
            race: nil,
            gender: nil,
            color: nil,
            birth_date: nil,
            race_size: nil,
            particular_signs: nil,
            age_on_weeks: 0,
            age_status: nil,
            adoption_status: false,
            adoption_date: Date.utc_today()
  
  @adult_for_small_dogs 78
  @adult_for_big_dogs 104
  @weeks_for_adoption 12
  
  alias __MODULE__

  @doc """
  Creates a pet with the basic information:
    > name
    > race
    > race
    > gender
    > color
    > birth_date
    > race_size
    > particular_signs
  """
  @spec create_pet(map) :: Pet
  def create_pet(params) do
    params
    |> _cast_string_to_date()
    |> get_age_on_weeks()
    |> calculate_age_status()
    |> _cast_to_module_struct()
  end

  # Cast a string date in a map to a Date type
  @spec _cast_string_to_date(map) :: map
  defp _cast_string_to_date(
    %{
      birth_date: birth_date
    } = params) when is_binary(birth_date) do
    params
    |> Map.update!(:birth_date, &Date.from_iso8601!(&1))
    |> _cast_string_to_date()
  end

  # Case when date fields are actually Date type
  defp _cast_string_to_date(params), do: params

  @doc """
  Calculates the pet age on weeks
  """
  @spec get_age_on_weeks(map) :: map 
  def get_age_on_weeks(%{birth_date: birth_date} = params) do
    age_on_weeks = _get_weeks_since_birth_date(birth_date)
    Map.put(params, :age_on_weeks, age_on_weeks)
  end

  # Get the weeks since the birth date
  @spec _get_weeks_since_birth_date(Date) :: integer
  defp _get_weeks_since_birth_date(birth_date) do
    today = Date.utc_today()
    Timex.diff(today, birth_date, :weeks)
  end

  @doc """
  Using the age on weeks determiates if the pet is an adult or a puppy
  """
  @spec calculate_age_status(map) :: map
  def calculate_age_status(
    %{
      race_size: size
    } = params) when size == :small or size == :medium do
    case params.age_on_weeks do
      weeks when weeks < @adult_for_small_dogs ->
        Map.put(params, :age_status, :puppy)
      _ ->
        Map.put(params, :age_status, :adult)
    end
  end

  def calculate_age_status(
    %{
      race_size: size
    } = params) when size == :large or size == :giant do
    case params.age_on_weeks do
      weeks when weeks < @adult_for_big_dogs ->
        Map.put(params, :age_status, :puppy)
      _ ->
        Map.put(params, :age_status, :adult)
    end
  end

  # Merge the map into the defined struct
  @spec _cast_to_module_struct(map) :: struct
  defp _cast_to_module_struct(params) do
    struct(__MODULE__, params)
  end

  @doc """
  Set a pet in adoption or rejects the request
  """
  @spec update_adoption_status(Pet, atom) :: Pet | {:error, String.t()}
  def update_adoption_status(pet, adoption_status) do
    with \
      :ok <- _can_be_set_in_adoption?(pet),
      {:ok, _} <- Map.fetch(pet, :adoption_status)
    do
      Map.put(pet, :adoption_status, adoption_status)
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  # Using the age on weeks since birth_date determinates of the pet can be
  # set in adoption
  @spec _can_be_set_in_adoption?(Pet) :: :ok | {:error, String.t()}
  defp _can_be_set_in_adoption?(pet) do
    case _get_weeks_since_birth_date(pet.birth_date) do
      weeks when weeks >= @weeks_for_adoption -> :ok
      _ -> {:error, "Puppies can be set in adoption 12 weeks after born"}
    end
  end
end