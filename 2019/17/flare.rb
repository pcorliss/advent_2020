require 'set'
require '../lib/intcode.rb'
require '../lib/grid.rb'

module Advent

  class Flare
    attr_accessor :debug

    def initialize(input)
      @debug = false
    end

    def debug!
      @debug = true
    end
  end
end