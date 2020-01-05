defmodule Anubis.Pet do

  defstruct uuid: nil,
            name: nil,
            species: nil,
            race: nil,
            gender: nil,
            color: nil,
            birth_date: nil,
            race_size: nil,
            particular_signs: nil,
            age_on_weeks: 0,
            age_status: nil,
            death_date: nil,
            general_status: :alive,
            adoption_status: false,
            adoption_date: nil

  @adult_for_small_dogs 78
  @adult_for_big_dogs 104
  @weeks_for_adoption 12

  @atom_values [
    :gender,
    :race_size,
    :species
  ]

  alias __MODULE__

  @doc """
  Creates a pet with the basic information:
    > name
    > race
    > species
    > gender
    > color
    > birth_date
    > race_size
    > particular_signs
  """
  @spec create_pet(map) :: Pet
  def create_pet(params) do
    params
    |> _prepare_params()
    |> _cast_string_to_date()
    |> get_age_on_weeks()
    |> calculate_age_status()
    |> _generate_pet_uuid()
    |> _cast_to_module_struct()
  end

  # Preparates params with the expected format
  defp _prepare_params(map) do
    map 
    |> _cast_keys_to_atoms()
    |> _cast_strings_to_atoms()
  end

  # Converts map key in strings to atoms
  @spec _cast_keys_to_atoms(map) :: map
  defp _cast_keys_to_atoms(map) do
    for {key, val} <- map, into: %{} do
      {String.to_atom(key), val}
    end
  end

  # Converts string values to atoms depe key
  @spec  _cast_strings_to_atoms(map) :: map
  defp _cast_strings_to_atoms(map) do
    Enum.reduce(@atom_values, map, fn item, map -> 
      if Map.get(map, item) do
        Map.put(map, item, String.to_atom(map[item]))
      end
    end)
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
  def calculate_age_status(%{race_size: size} = params) when is_binary(size) do
    params
    |> Map.update!(:race_size, &String.to_atom(&1))
    |> calculate_age_status()
  end

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

  defp _generate_pet_uuid(pet) do
    pet_uuid =  UUID.uuid4(:default)
    Map.put(pet, :uuid, pet_uuid)
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
  def update_adoption_status(
    %{
      adoption_status: :in_adoption
    } = pet,
    :adopted) do
    with \
      {:ok, _} <- Map.fetch(pet, :adoption_date),
      {:ok, _} <- Map.fetch(pet, :adoption_status)
    do
      pet
      |> Map.put(:adoption_date, Date.utc_today())
      |> Map.put(:adoption_status, :adopted)
    else
      :error -> {:error, "Error"}
    end
  end

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

  @doc """
  update de general_status, it could be :ok, :lost, :death or not corresponding
  status with the adopted_status

  if the status is :death, updates the :death_date
  """
  @spec update_general_status(Pet, atom) :: Pet | {:error, String.t()}
  def update_general_status(pet, status) do
    case Map.fetch(pet, :general_status) do
      {:ok, _} ->
        Map.put(pet, :general_status, status)
      :error ->
        {:error, "Cannot update general status"}
    end
  end

  @doc """
  Update a pet as death and the relevant information for this
  """
  @spec mask_pet_as_death(Pet, String.t()) :: Pet | {:error, String.t()}
  def mask_pet_as_death(pet, death_date) do
    death_date = _cast_to_date(death_date)
    alive_weeks = _get_alive_weeks(pet, death_date)

    with \
      pet <- update_general_status(pet, :death),
      {:ok, _} <- Map.fetch(pet, :age_on_weeks),
      {:ok, nil} <- Map.fetch(pet, :death_date)
    do
      pet
      |> Map.put(:age_on_weeks, alive_weeks)
      |> Map.put(:death_date, death_date)
    else
      :error -> {:error, "Error"}
      {:error, error} -> {:error, error}
    end
  end

  defp _cast_to_date(date_string) when is_binary(date_string) do
    Date.from_iso8601!(date_string)
  end

  defp _cast_to_date(date_string), do: date_string

  defp _get_alive_weeks(pet, death_date) do
    Timex.diff(pet.birth_date, death_date)
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
