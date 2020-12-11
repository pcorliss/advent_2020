require '../seat.rb'
require 'rspec'
require 'pry'

describe Advent do

  let(:input) {
    <<~EOS
      L.LL.LL.LL
      LLLLLLL.LL
      L.L.L..L..
      LLLL.LL.LL
      L.LL.LL.LL
      L.LLLLL.LL
      ..L.L.....
      LLLLLLLLLL
      L.LLLLLL.L
      L.LLLLL.LL
    EOS
  }

  let(:iter1) {
    <<~EOS
#.##.##.##
#######.##
#.#.#..#..
####.##.##
#.##.##.##
#.#####.##
..#.#.....
##########
#.######.#
#.#####.##
    EOS
  }

  let(:iter2) {
    <<~EOS
#.LL.L#.##
#LLLLLL.L#
L.L.L..L..
#LLL.LL.L#
#.LL.LL.LL
#.LLLL#.##
..L.L.....
#LLLLLLLL#
#.LLLLLL.L
#.#LLLL.##
    EOS
  }
  let(:iter3) {
    <<~EOS
#.##.L#.##
#L###LL.L#
L.#.#..#..
#L##.##.L#
#.##.LL.LL
#.###L#.##
..#.#.....
#L######L#
#.LL###L.L
#.#L###.##
    EOS
  }
  let(:iter4) {
    <<~EOS
#.#L.L#.##
#LLL#LL.L#
L.L.L..#..
#LLL.##.L#
#.LL.LL.LL
#.LL#L#.##
..L.L.....
#L#LLLL#L#
#.LLLLLL.L
#.#L#L#.##
    EOS
  }
  let(:iter5) {
    <<~EOS
#.#L.L#.##
#LLL#LL.L#
L.#.L..#..
#L##.##.L#
#.#L.LL.LL
#.#L#L#.##
..L.L.....
#L#L##L#L#
#.LLLLLL.L
#.#L#L#.##
    EOS
  }
  describe Advent::Seat do
    let(:ad) { Advent::Seat.new(input) }

    describe "#new" do
      it "loads an array of seats" do
        expect(ad.seats).to be_a(Array)
        expect(ad.seats.first).to eq('L')
      end

      it "tracks width and height" do
        expect(ad.width).to eq(10)
        expect(ad.height).to eq(10)
      end
    end

    describe "#adjacent_seats" do
      it "returns the adjacent seats given a pos" do
        expect(ad.adjacent_seats(11)).to eq(%w(L . L L L L . L))
      end

      it "returns adjacent seats on a corner UL" do
        expect(ad.adjacent_seats(0)).to eq(%w(. L L))
      end

      it "returns adjacent seats on a corner BR" do
        expect(ad.adjacent_seats(99)).to eq(%w(. L L))
      end
    end

    describe "#tick!" do
      it "returns the numbers of changes" do
        expect(ad.tick!).to eq(71)
      end

      context "mutates the state" do
        it "changes empty seats with no adjacent filled seats to full" do
          ad.tick!
          expect(ad.adjacent_seats(0)).to eq(%w(. # #))
        end

        it "changes filed seats with four or more seats adjacent to empty" do
          ad.tick!
          ad.tick!
          expect(ad.adjacent_seats(0)).to eq(%w(. # L))
        end
      end
    end

    describe "#occupied_seats" do
      it "returns a count of occupied seats" do
        expect(ad.occupied_seats).to eq(0)
      end

      it "returns a count after changes" do
        expect(ad.tick!).to eq(ad.occupied_seats)
      end
    end

    context "validation" do
      it "reaches a stable state" do
        expect(ad.tick!).to eq(71)
        expect(ad.tick!).to eq(51)
        expect(ad.tick!).to eq(31)
        expect(ad.tick!).to eq(21)
        expect(ad.tick!).to eq(7)
        expect(ad.tick!).to eq(0)
        expect(ad.tick!).to eq(0)
        expect(ad.occupied_seats).to eq(37)
      end

      it "has the expected seat configuration" do
        expect(ad.seats).to eq( Advent::Seat.new(input).seats )
        ad.tick!
        expect(ad.seats).to eq( Advent::Seat.new(iter1).seats )
        ad.tick!
        expect(ad.seats).to eq( Advent::Seat.new(iter2).seats )
        ad.tick!
        expect(ad.seats).to eq( Advent::Seat.new(iter3).seats )
        ad.tick!
        expect(ad.seats).to eq( Advent::Seat.new(iter4).seats )
        ad.tick!
        expect(ad.seats).to eq( Advent::Seat.new(iter5).seats )
      end
    end
  end
end
