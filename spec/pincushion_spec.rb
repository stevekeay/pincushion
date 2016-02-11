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
    cat = animals.that_is(:carnivore).named("Mee-mow")
    mittens = animals.find("Mee-mow")
    assert_equal mittens.class, cat
    assert mittens.carnivore?
    refute mittens.herbivore?
  end

  it "doesn't allow unregistered predicates" do
    animals = Module.new
    animals.include Pincushion
    animals.predicates :herbivore

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
    animals = Module.new
    animals.include Pincushion
    assert_raises Pincushion::MissingPredicateError do
      animals.that_is(:carnivore)
    end
  end
end
