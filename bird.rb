require "matrix"
require "rubystats"
require "ruby2d"

class Bird
	attr_accessor :position, :direction, :index, :start_x, :start_y, :stop_x, :stop_y

	def initialize(position)
		@position = position
		@direction = rand(0..2*Math::PI)
	end

	# This initializes the :index, :start_x, :start_y,
	# :stop_x, and :stop_y variables.
	def seed_start_stop(index, birds, is_x)
		@index = index
		birds_length = birds.size
		coord = is_x ? 0 : 1

		# Find the starting x value.
		i = index
		my_coord = @position[coord]
		while i > 0 && my_coord - birds[i].position[coord] < 5
			i -= 1
		end
		is_x ? @start_x = i : @start_y = i

		# Find the stopping x value similarly to the starting x.
		i = index
		while i < birds_length && birds[i].position[coord] - my_coord < 5
			i += 1
		end
		is_x ? @stop_x = i : @stop_y = i
	end

	def velocity
		Vector[Math.cos(@direction), Math.sin(@direction)]
	end

	def update
		@position += velocity

		if @position[0] < 0 || @position[0] > 800 || @position[1] < 0 || @position[1] > 600
			# Restart this bird.
			initialize(Vector[rand(800), rand(600)])
		end
	end

	def square
		Square.new(x: @position[0], y: @position[1], size: 2, color: "black")
	end

	def collision_square
		Square.new(x: position[0] - 5, y: @position[1] - 5, size: 10, color: "silver")
	end
end
