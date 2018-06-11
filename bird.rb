require "matrix"
require "rubystats"
require "ruby2d"

class Bird
	attr_accessor :position, :direction

	def initialize(position)
		@position = position
		@direction = rand(0..2*Math::PI)
	end

	def velocity
		Vector[Math.cos(@direction), Math.sin(@direction)]
	end

	def update
		@position += velocity

		if @position[0] < 0 || @position[0] > 800 || @position[1] < 0 || @position[1] > 600
			@direction += Math::PI
		end
	end

	def square
		Square.new(x: @position[0], y: @position[1], size: 2, color: "black")
	end

	def collision_square
		Square.new(x: position[0] - 5, y: @position[1] - 5, size: 10, color: "silver")
	end
end
