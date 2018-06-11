require "matrix"
require "rubystats"
require "ruby2d"

class Bird
	attr_accessor :position, :velocity

	def initialize(position, direction)
		@position = position
		@velocity = Vector[Rubystats::NormalDistribution.new(direction[0], 0.1).rng * 10, Rubystats::NormalDistribution.new(direction[1], 0.1).rng * 10]
		@new_velocity = nil
	end

	def update
		@position += @velocity

		if @position[0] < 0 || @position[0] > 800
			@velocity = Vector[-@velocity[0], @velocity[1]]
		end

		if @position[1] < 0 || @position[1] > 600
			@velocity = Vector[@velocity[0], -@velocity[1]]
		end
	end

	def square
		Square.new(x: @position[0], y: @position[1], size: 5, color: "black")
	end

	def circle
		Square.new(x: position[0] - 5, y: @position[1] - 5, size: 10, color: "silver")
	end
end
