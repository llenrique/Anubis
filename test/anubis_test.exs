defmodule Anubis.PetTest do
  use ExUnit.Case

  alias Anubis.Pet, as: Pet

  @basic_pet %{
    name: "Tony",
    adoption_age: :puppy,
    adoption_date: "2019-07-16",
    birth_date: "2019-06-16",
    pet_type: :canine,
    race_size: :small,
    race: "Chihuahua",
    gender: :male,
    adoption_type: :given
  }

  @adult_pet %{
    name: "Duquesa",
    adoption_age: :adult,
    adoption_date: "2010-04-25",
    pet_type: :canine,
    race_size: :large,
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
    basic_pet = %{
      name: "Dick",
      adoption_age: :puppy,
      adoption_date: "2005-08-24",
      adoption_date: "2005-08-24",
      pet_type: :canine,
      race_size: :small,
      race: "French Mini",
      gender: :male,
      adoption_type: :given,
      birth_date: ~D[2005-07-24]
    }

    basic_pet = Pet.create_pet basic_pet

    basic_pet = Pet.update_death_date_for_pet(basic_pet, "2018-09-03")

    assert basic_pet.alive_status == :death
  end

  test "Accepts Date type on params" do
    basic_pet = %{
      name: "Dick",
      adoption_age: :puppy,
      adoption_date: "2005-08-24",
      adoption_date: "2005-08-24",
      pet_type: :canine,
      race_size: :small,
      race: "French Mini",
      gender: :male,
      adoption_type: :given,
      birth_date: ~D[2005-07-24]
    }

    pet = Pet.create_pet basic_pet

    assert pet.adoption_date == ~D[2005-08-24]
  end
  
  test "Calculates age status for a large pet" do
    basic_pet = %{
      name: "Dick",
      adoption_age: :puppy,
      adoption_date: ~D[2005-08-24],
      birth_date: "2005-06-16",
      pet_type: :canine,
      race_size: :large,
      race: "French Mini",
      gender: :male,
      adoption_type: :given
    }

    pet = Pet.create_pet basic_pet

    assert pet.age_status == :adult
  end
end
