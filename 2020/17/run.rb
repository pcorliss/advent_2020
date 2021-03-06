#!/usr/bin/env ruby

require_relative 'cubes'

input = File.read('./input.txt')

ad = Advent::Cubes.new(input)
6.times { ad.cycle! }
puts "6 Cycle Count: #{ad.grid.count}"
ad = Advent::Cubes.new(input, 4)
6.times { ad.cycle! }
puts "4D 6 Cycle Count: #{ad.grid.count}"
