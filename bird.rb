require "matrix"
require "ruby2d"

CENTER = [400, 300]

class Bird
	attr_reader :position, :direction, :velocity

	def initialize(position, direction, strength, verbose)
		set_direction direction

		@square = Square.new(x: position[0], y: position[1], size: 2, color: "black")
		@position = position

		@strength = strength

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

	def set_direction(direction)
		@direction = direction
		@velocity = Vector[Math.cos(direction), Math.sin(direction)]
	end

	def set_velocity(velocity)
		@velocity = velocity
	end

	def distance_to(bird)
		other_position = bird.position

		Math.sqrt(((@position[0] - other_position[0]) ** 2) + ((@position[1] - other_position[1]) ** 2))
	end

	def direction_to(point)
		Math.atan2(point[1] - @position[1], point[0] - @position[0])
	end

	def mean_angle(angles)
		n = angles.length
		sin_values = angles.sum { |a| a[:weight] * Math.sin(a[:angle]) }
		cos_values = angles.sum { |a| a[:weight] * Math.cos(a[:angle]) }

		Math.atan2(sin_values.fdiv(n), cos_values.fdiv(n))
	end

	# The bird's direction will change to a weighted average of its own direction
	# and those around it.
	def react_to_birds(near_birds)
		return if near_birds.count == 0

		directions = near_birds.map(&:direction)
		average = mean_angle(directions.map { |d| { weight: 1, angle: d } })

		new_direction = mean_angle([
			{
				weight: @strength,
				angle: @direction
			},
			{
				weight: 1 - @strength,
				angle: average
			}
		])
		set_direction new_direction
	end

	def stay_in_bounds
		if @square.x < 10 || @square.x > 790 || @square.y < 10 || @square.y > 590
			modified_strength = @strength * 0.3
			excess = 0.3 - modified_strength

			#new_direction = modified_strength * @direction + (0.7 + excess) * direction_to(CENTER)
			set_direction mean_angle([
				{
					weight: modified_strength,
					angle: @direction
				},
				{
					weight: 0.7 + excess,
					angle: direction_to(CENTER)
				}
			])
		end
	end

	def update
		@square.x += @velocity[0]
		@square.y += @velocity[1]

		@position = Vector[@square.x, @square.y]
	end
end
