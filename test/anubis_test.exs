defmodule Anubis.PetTest do
  use ExUnit.Case

  alias Anubis.Pet, as: Pet

  test "Creates a basic pet" do
    basic_pet = %{
      name: "Dick",
      adoption_age: :puppy,
      obtained_date: "2005-08-24",
      pet_type: :canine,
      size: :small,
      race: "French Mini",
      gender: :male
    }

    basic_pet = Pet.create_pet basic_pet

    assert basic_pet.age_status == :adult
    assert basic_pet.alive_status == :alive
  end
end
