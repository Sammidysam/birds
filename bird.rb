require "matrix"
require "rubystats"
require "ruby2d"

class Bird
	attr_reader :position, :velocity

	def initialize(position, direction, verbose)
		set_direction direction

		@square = Square.new(x: position[0], y: position[1], size: 2, color: "black")

		if verbose
			@collision_square = Circle.new(x: position[0] + 1, y: position[1] + 1, radius: 5, color: "silver")
			@movement_vector = Line.new(
				x1: position[0], y1: position[1],
				x2: position[0] + (@velocity[0] * 3), y2: position[1] + (@velocity[1] * 3),
				width: 2,
				color: "lime"
			)
		end
	end

	def get_position
		Vector[@square.x, @square.y]
	end

	def set_direction(direction)
		@velocity = Vector[Math.cos(direction), Math.sin(direction)]
	end

	def set_velocity(velocity)
		@velocity = velocity
	end

	def update
		@square.x += @velocity[0]
		@square.y += @velocity[1]
	end
end
