require './rad.rb'
require 'rspec'
require 'pry'

describe Advent do

  let(:input) {
    <<~EOS
      The first floor contains a hydrogen-compatible microchip and a lithium-compatible microchip.
      The second floor contains a hydrogen generator.
      The third floor contains a lithium generator.
      The fourth floor contains nothing relevant.
    EOS
  }

  describe Advent::Rad do
    let(:ad) { Advent::Rad.new(input) }

    describe "#new" do
      it "inits a list of floors and their contents" do
        expect(ad.floors.count).to eq(4)
        expect(ad.obj_lookup(ad.floors.first)).to contain_exactly("hydrogen-m", "lithium-m")
      end

      it "handles a longer list" do
        new_input = "The first floor contains a strontium generator, a strontium-compatible microchip, a plutonium generator, and a plutonium-compatible microchip.\n"
        ad = Advent::Rad.new(new_input)
        expect(ad.obj_lookup(ad.floors.first)).to contain_exactly(
          "strontium-g", "plutonium-g",
          "strontium-m", "plutonium-m"
        )
      end
    end

    describe "#success?" do
      it "returns true if the state is successful" do
        state = [4, [], [], [], ad.id_lookup(["lithium-m", "lithium-g", "hydrogen-g", "hydrogen-m"])]
        expect(ad.success?(state)).to be_truthy
      end

      it "returns false if the elevator is not at the top" do
        state = [3, [], [], [], ad.id_lookup(["lithium-m", "lithium-g", "hydrogen-g", "hydrogen-m"])]
        expect(ad.success?(state)).to be_falsey
      end

      it "returns false if another floor has something on it" do
        state = [4, ad.id_lookup(['lithium-m']), [], [], ad.id_lookup(["lithium-g", "hydrogen-g", "hydrogen-m"])]
        expect(ad.success?(state)).to be_falsey
      end
    end

    describe "#failure?" do
      it "returns false if a floor has only matched chips and generators" do
        state = [4, [], [], [], ad.id_lookup(["lithium-m", "lithium-g", "hydrogen-g", "hydrogen-m"])]
        expect(ad.failure?(state)).to be_falsey
      end

      it "returns true if a floor has unmatched chips and a generator" do
        state = [4, [], [], [], ad.id_lookup(["lithium-g", "hydrogen-m"])]
        expect(ad.failure?(state)).to be_truthy
      end

      it "returns false if a floor has an unmatched chip but no generators" do
        state = [4, [], [], [], ad.id_lookup(["hydrogen-m"])]
        expect(ad.failure?(state)).to be_falsey
      end

      it "returns false if a floor has an unmatched generator but no chips" do
        state = [4, [], [], [], ad.id_lookup(["hydrogen-g"])]
        expect(ad.failure?(state)).to be_falsey
      end

      it "returns true if a floor has an unmatched chip" do
        state = [4, [], [], [], ad.id_lookup(["lithium-g", "lithium-m", "hydrogen-m"])]
        expect(ad.failure?(state)).to be_truthy
      end
    end

    describe "#pairing_state" do
      it "includes unmatched items" do
        state = [4, [], [], [], ad.id_lookup(["hydrogen-m"])]
        expect(ad.pairing_state(state)).to eq([
          4, [0, Set.new], [0, Set.new], [0, Set.new], [0, Set.new(ad.id_lookup(["hydrogen-m"]))]
        ].hash)
      end

      it "counts matched pairs" do
        state = [4, [], [], [], ad.id_lookup(["hydrogen-m", "hydrogen-g"])]
        expect(ad.pairing_state(state)).to eq([
          4, [0, Set.new], [0, Set.new], [0, Set.new], [2, Set.new()]
        ].hash)
      end
    end

    describe "#find_solution" do
      it "returns the steps" do
        ad.debug!
        expect(ad.find_solution).to eq(11)
      end
    end

    describe "#find_solution_prime" do
      it "returns the steps" do
        ad.debug!
        expect(ad.find_solution_prime).to eq(11)
      end
    end

    context "validation" do
    end
  end
end
