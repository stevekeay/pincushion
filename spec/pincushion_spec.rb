require "spec_helper"
require "pincushion"
require "pincushion/version"

describe Pincushion do
  let(:klass) { Pincushion }

  it "has a version number" do
    refute_nil ::Pincushion::VERSION
  end

  it "can be used to define a category with properties" do
    animals = Module.new
    animals.include Pincushion
    animals.predicates :carnivore, :herbivore
    cat = animals.that_is(:carnivore).named("Mittens")
    assert_equal animals.find("Mittens").class, cat
    assert animals.find("Mittens").carnivore?
    refute animals.find("Mittens").herbivore?
  end
end
