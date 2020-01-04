defmodule Anubis.PetTest do
  use ExUnit.Case

  alias Anubis.Pet, as: Pet

  @basic_big_puppy_pet %{
    "name" => "Rambo",
    "species" => :canine,
    "race" => "Golden Chocolate",
    "gender" => :male,
    "color" => :brown,
    "race_size" => :large,
    "birth_date" => Timex.shift(Date.utc_today(), weeks: -1)
  }

  @basic_big_adult_pet %{
    "birth_date" => "2015-05-17",
    "color" => "white/brown",
    "gender" => "male",
    "name" => "Hulk",
    "race" => "PitBull",
    "race_size" => "large",
    "species" => "canine"
  }

  @basic_small_puppy_pet %{
    "name" => "Rambo",
    "species" => :canine,
    "race" => "Golden Chocolate",
    "gender" => :male,
    "color" => :brown,
    "race_size" => :small,
    "birth_date" => Timex.shift(Date.utc_today(), weeks: -1)
  }

  @basic_small_adult_pet %{
    "name" => "Rambo",
    "species" => :canine,
    "race" => "Golden Chocolate",
    "gender" => :male,
    "color" => :brown,
    "race_size" => :small,
    "birth_date" => Timex.shift(Date.utc_today(), weeks: -78)
  }

  test "create_pet/1 Can create a pet with basic data" do
    created_pet = Pet.create_pet @basic_big_puppy_pet

    assert %Anubis.Pet{} = created_pet
    assert created_pet.species == :canine
    assert created_pet.name == "Rambo"
    assert created_pet.gender == :male
    assert created_pet.race == "Golden Chocolate"
    assert created_pet.age_on_weeks == 1
    assert created_pet.age_status == :puppy

  end

  test "calculate_age_status/1 determinates a small puppy pet" do
    created_pet = Pet.create_pet @basic_small_adult_pet

    assert %Anubis.Pet{} = created_pet
    assert created_pet.species == :canine
    assert created_pet.name == "Rambo"
    assert created_pet.gender == :male
    assert created_pet.race == "Golden Chocolate"
    assert created_pet.age_on_weeks == 78
    assert created_pet.age_status == :adult

  end

  test "calculate_age_status/1 Can determiates a big adlut pet" do
    created_pet = Pet.create_pet @basic_big_adult_pet

    assert %Anubis.Pet{} = created_pet
    assert created_pet.species == "canine"
    assert created_pet.name == "Hulk"
    assert created_pet.gender == "male"
    assert created_pet.race == "PitBull"
    assert created_pet.age_on_weeks == 241
    assert created_pet.age_status == :adult

  end

  test "calculate_age_status/1 Can determiates a small puppy pet" do
    created_pet = Pet.create_pet @basic_small_puppy_pet

    assert %Anubis.Pet{} = created_pet
    assert created_pet.species == :canine
    assert created_pet.name == "Rambo"
    assert created_pet.gender == :male
    assert created_pet.race == "Golden Chocolate"
    assert created_pet.age_on_weeks == 1
    assert created_pet.age_status == :puppy

  end

  test "update_adoption_status/1 Can set in adoption a pet" do
    pet_map = %{
      "name" => "Mila",
      "species" => :canine,
      "race" => "Schnauser",
      "gender" => :female,
      "color" => :grey,
      "race_size" => "small",
      "birth_date" => Timex.shift(Date.utc_today(), weeks: -12)
    }

    created_pet =
      pet_map
      |> Anubis.Pet.create_pet()
      |> Anubis.Pet.update_adoption_status(:in_adoption)

    assert created_pet.adoption_status == :in_adoption
  end

  test "update_adoption_status/1 Can't set in adoption a pet" do
    pet_map = %{
      "name" => "Mila",
      "species" => :canine,
      "race" => "Schnauser",
      "gender" => :female,
      "color" => :grey,
      "race_size" => "small",
      "birth_date" => Timex.shift(Date.utc_today(), weeks: -10)
    }

    created_pet =
      pet_map
      |> Anubis.Pet.create_pet()
      |> Anubis.Pet.update_adoption_status(:in_adoption)

    assert {:error, reason} = created_pet
    assert reason == "Puppies can be set in adoption 12 weeks after born"
  end

  test "update_adoption_status/1 Set a pet as :adopted when pet is :in_adoption" do
    in_adoption_pet = %Anubis.Pet{
      adoption_date: ~D[2009-12-31],
      adoption_status: :in_adoption,
      age_on_weeks: 316,
      age_status: :adult,
      birth_date: ~D[2009-01-01],
      color: :golden,
      gender: :female,
      name: "Duquesa",
      particular_signs: nil,
      race: "Labrador",
      race_size: :large,
      species: :canine
    }

    adopted_pet = Pet.update_adoption_status(in_adoption_pet, :adopted)

    assert in_adoption_pet.adoption_status != adopted_pet.adoption_status
    assert adopted_pet.adoption_status == :adopted
    assert adopted_pet.adoption_date == Date.utc_today()
  end

  test "update general_status" do
    pet = %Anubis.Pet{
      adoption_date: ~D[2009-12-31],
      adoption_status: :in_adoption,
      age_on_weeks: 316,
      age_status: :adult,
      birth_date: ~D[2009-01-01],
      color: :golden,
      gender: :female,
      name: "Duquesa",
      particular_signs: nil,
      race: "Labrador",
      race_size: :large,
      species: :canine,
      general_status: :ok,
    }

    pet = Pet.update_general_status(pet, :lost)

    assert pet.general_status == :lost
  end

  test "mark a pet as death in general_status" do
    pet = %Anubis.Pet{
      adoption_date: ~D[2009-12-31],
      adoption_status: :in_adoption,
      age_on_weeks: 316,
      age_status: :adult,
      birth_date: ~D[2009-01-01],
      color: :golden,
      gender: :female,
      name: "Duquesa",
      particular_signs: nil,
      race: "Labrador",
      race_size: :large,
      species: :canine,
      general_status: :alive,
      death_date: nil
    }

    pet = Pet.mask_pet_as_death(pet, "2018-09-03")

    assert pet.general_status == :death
    assert pet.death_date == ~D[2018-09-03]
  end
end
