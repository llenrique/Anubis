defmodule Anubis.PetTest do
  use ExUnit.Case

  alias Anubis.Pet, as: Pet

  @basic_pet %{
    name: "Dick",
    adoption_age: :puppy,
    obtained_date: "2005-08-24",
    pet_type: :canine,
    size: :small,
    race: "French Mini",
    gender: :male,
    adoption_type: :given
  }

  @adult_pet %{
    name: "Duquesa",
    adoption_age: :adult,
    obtained_date: "2010-04-25",
    pet_type: :canine,
    size: :large,
    race: "Labrador",
    gender: :female,
    adoption_type: :street
  }
  
  test "Creates a basic pet" do

    basic_pet = Pet.create_pet @basic_pet

    assert basic_pet.age_status == :adult
    assert basic_pet.alive_status == :alive
  end

  test "Marks a pet as death" do
    basic_pet = Pet.create_pet @basic_pet
  
    basic_pet = Pet.update_death_date_for_pet(basic_pet, "2018-09-03")

    assert basic_pet.alive_status == :death
  end


  test "Calculates age time for adult pet" do
    adult_pet = Pet.create_pet @adult_pet

    assert adult_pet.age_status == :adult
    assert adult_pet.age_time_in_months == "Must be calculated for a vet"
  end

  test "Accepts Date type on params" do
    basic_pet = %{
      name: "Dick",
      adoption_age: :puppy,
      obtained_date: ~D[2005-08-24],
      pet_type: :canine,
      size: :small,
      race: "French Mini",
      gender: :male,
      adoption_type: :given
    }

    pet = Pet.create_pet basic_pet

    assert pet.obtained_date == ~D[2005-08-24]
  end
  
  test "Calculates age status for a large pet" do
    basic_pet = %{
      name: "Dick",
      adoption_age: :puppy,
      obtained_date: ~D[2005-08-24],
      pet_type: :canine,
      size: :large,
      race: "French Mini",
      gender: :male,
      adoption_type: :given
    }

    pet = Pet.create_pet basic_pet

    assert pet.age_status == :adult
  end
end
