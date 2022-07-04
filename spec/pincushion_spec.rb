require "spec_helper"
require "json"
require "pincushion"
require "pincushion/version"

describe Pincushion do
  let(:klass) { Pincushion }

  let(:animal_data) do
    [
      { identifier: "Mee-mow", carnivore: true, herbivore: false },
      { identifier: "Jake", carnivore: true, herbivore: true },
      { identifier: "B-Mo", carnivore: false, herbivore: false }
    ]
  end

  let(:animal_data_csv) do
    "identifier,carnivore,herbivore\n"\
    "Mee-mow,true,false\n"\
    "Jake,true,true\n"\
    "B-Mo,false,false\n"
  end

  let(:animal_data_json) do
    "[{\"identifier\":\"Mee-mow\",\"carnivore\":true,\"herbivore\":false},"\
    "{\"identifier\":\"Jake\",\"carnivore\":true,\"herbivore\":true},"\
    "{\"identifier\":\"B-Mo\",\"carnivore\":false,\"herbivore\":false}]"
  end

  it "has a version number" do
    refute_nil ::Pincushion::VERSION
  end

  it "can be used to define a category with properties" do
    animals = Module.new { include Pincushion }
    animals.predicates :carnivore, :herbivore
    cat = animals.that_is(:carnivore).named("Mee-mow")
    mittens = animals.find("Mee-mow")
    assert_equal mittens.class, cat
    assert mittens.carnivore?
    refute mittens.herbivore?
  end

  it "doesn't allow unregistered predicates" do
    animals = Module.new { include Pincushion }
    animals.predicates :herbivore

    elephants = animals.that_are(:herbivore)
    elephants.that_is.named("Tree Trunks")

    assert_raises Pincushion::MissingPredicateError do
      animals.that_is(:carnivore)
    end

    assert_raises Pincushion::MissingPredicateError do
      cat = animals.that_is
      cat.is(:carnivore)
    end

    assert_raises Pincushion::MissingPredicateError do
      cat = animals.that_is
      cat.is_not(:carnivore)
    end

    assert_raises Pincushion::MissingPredicateError do
      animals.that_are(:carnivore)
    end
  end

  it "doesn't allow unregistered predicates (empty set)" do
    animals = Module.new { include Pincushion }
    assert_raises Pincushion::MissingPredicateError do
      animals.that_is(:carnivore)
    end
  end

  it "round-trips to and from arrays of hashes" do
    animals = Pincushion.from_rows(animal_data)
    assert_equal animals.rows, animal_data
  end

  it "round-trips CSV with the csv_serializer plugin" do
    Pincushion.plugin :csv_serializer
    animals = Pincushion.from_csv(animal_data_csv)
    animals.plugin :csv_serializer
    assert_equal animals.to_csv(write_headers: true), animal_data_csv
  end

  it "round-trips JSON with the json_serializer plugin" do
    Pincushion.plugin :json_serializer
    animals = Pincushion.from_json(animal_data_json)
    animals.plugin :json_serializer
    assert_equal animals.to_json, animal_data_json
  end

  it "creates question-mark methods, not is-methods" do
    animals = Module.new { include Pincushion }
    animals.predicates :herbivore
    elephants = animals.that_is(:herbivore)
    assert elephants.new("").herbivore?

    assert_raises(NoMethodError) do
      elephants.new("").is_herbivore
    end

    assert_raises(NoMethodError) do
      elephants.new("").is_herbivore?
    end
  end
end
