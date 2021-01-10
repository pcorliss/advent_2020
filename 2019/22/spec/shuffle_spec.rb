require './shuffle.rb'
require 'rspec'
require 'pry'

describe Advent do

  let(:input) {
    <<~EOS
deal with increment 34
deal into new stack
cut 1712
    EOS
  }

  describe Advent::Shuffle do
    let(:ad) { Advent::Shuffle.new(input) }
    let(:big_deck) { 10007.times.to_a }

    describe "#new" do
      it "instantiates a new deck with 10007 cards" do
        expect(ad.deck).to eq(big_deck)
      end

      it "loads instructions" do
        expect(ad.instructions).to eq([
          "deal with increment 34",
          "deal into new stack",
          "cut 1712",
        ])
      end
    end

    describe "#deal_into_new_stack" do
      it "reverses the order" do
        ad.deal_into_new_stack!
        expect(ad.deck.to_a).to eq(big_deck.reverse)
      end
    end

    describe "#deal_with_increment" do
      it "takes an argument" do
        ad.deal_with_increment!(1)
        expect(ad.deck.to_a).to eq(big_deck)
      end

      it "skips spaces and wraps around" do
        ad = Advent::Shuffle.new(input, 10)
        ad.deal_with_increment!(3)
        expect(ad.deck.to_a).to eq([0,7,4,1,8,5,2,9,6,3])
      end
    end

    describe "#cut" do
      it "rotates the deck by the argument passed" do
        ad = Advent::Shuffle.new(input, 10)
        ad.cut!(3)
        expect(ad.deck.to_a).to eq([3,4,5,6,7,8,9,0,1,2])
      end

      it "rotates the deck by a negative amount" do
        ad = Advent::Shuffle.new(input, 10)
        ad.cut!(-4)
        expect(ad.deck.to_a).to eq([6,7,8,9,0,1,2,3,4,5])
      end
    end

    context "validation" do
      A_SAMPLE = <<~EOS
deal with increment 7
deal into new stack
deal into new stack
      EOS

      B_SAMPLE = <<~EOS
cut 6
deal with increment 7
deal into new stack
      EOS
      C_SAMPLE = <<~EOS
deal with increment 7
deal with increment 9
cut -2
      EOS

      D_SAMPLE = <<~EOS
deal into new stack
cut -2
deal with increment 7
cut 8
cut -4
deal with increment 7
cut 3
deal with increment 9
deal with increment 3
cut -1
      EOS

      {
        A_SAMPLE => [0,3,6,9,2,5,8,1,4,7],
        # B_SAMPLE => [3,0,7,4,1,8,5,2,9,6],
        # C_SAMPLE => [6,3,0,7,4,1,8,5,2,9],
        # D_SAMPLE => [9,2,5,8,1,4,7,0,3,6],
      }.each do |inp, expected|
        it "gets the expected result #{expected}" do
          ad = Advent::Shuffle.new(inp, 10)
          ad.run!
          expect(ad.deck.to_a).to eq(expected)
        end
      end
    end
  end
end