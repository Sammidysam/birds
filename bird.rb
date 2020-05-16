require "matrix"
require "ruby2d"

CENTER = [400, 300]

class Bird
	attr_reader :index, :position, :direction, :strength, :velocity

	def initialize(index, position, direction, strength, verbose)
		@index = index

		set_direction direction

		@square = Square.new(x: position[0], y: position[1], z: 2, size: 3, color: "black")
		@position = position

		@strength = strength

		@verbose = verbose
		if @verbose
			@collision_square = Circle.new(x: position[0] + 1.5, y: position[1] + 1.5, radius: 10, color: "silver")
			@movement_vector = Line.new(
				x1: position[0] + 1.5, y1: position[1] + 1.5,
				x2: position[0] + 1.5 + (@velocity[0] * 10), y2: position[1] + 1.5 + (@velocity[1] * 10),
				width: 3,
				color: "lime"
			)
		end
	end

	def seed_start_stop(birds_by_x, birds_by_y)
		in_range = false
		completed = false

		birds_by_x.each_with_index do |b, i|
			break if completed

			if !in_range && @position[0] - b.position[0] < 10
				in_range = true
				@start_x = i
			elsif in_range && b.position[0] - @position[0] > 10
				completed = true
				@stop_x = i
			end
		end

		@stop_x ||= birds_by_x.length - 1

		# Horribly repetitive and gross right now as a proof of concept.
		in_range = false
		completed = false

		birds_by_y.each_with_index do |b, i|
			break if completed

			if !in_range && @position[1] - b.position[1] < 10
				in_range = true
				@start_y = i
			elsif in_range && b.position[1] - @position[1] > 10
				completed = true
				@stop_y = i
			end
		end

		@stop_y ||= birds_by_y.length - 1
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
	def react_to_birds(birds_by_x, birds_by_y)
		# Possibly shrink.
		while @position[0] - birds_by_x[@start_x].position[0] >= 10
			@start_x += 1
		end

		while birds_by_x[@start_x].position[0] - @position[0] >= 10
			@start_x -= 1
		end

		while birds_by_x[@stop_x].position[0] - @position[0] >= 10
			@stop_x -= 1
		end

		while @position[0] - birds_by_x[@stop_x].position[0] >= 10
			@stop_x += 1
		end

		# Copied and pasted and bad.
		# Possibly expand.
		while @start_x > 0 && @position[0] - birds_by_x[@start_x - 1].position[0] < 10
			@start_x -= 1
		end

		while @stop_x < birds_by_x.length - 1 && birds_by_x[@stop_x + 1].position[0] - @position[0] < 10
			@stop_x += 1
		end

		# Possibly shrink.
		while @position[1] - birds_by_y[@start_y].position[1] >= 10
			@start_y += 1
		end

		while birds_by_y[@start_y].position[1] - @position[1] >= 10
			@start_y -= 1
		end

		while birds_by_y[@stop_y].position[1] - @position[1] >= 10
			@stop_y -= 1
		end

		while @position[1] - birds_by_y[@stop_y].position[1] >= 10
			@stop_y += 1
		end

		# Possibly expand.
		while @start_y > 0 && @position[1] - birds_by_y[@start_y - 1].position[1] < 10
			@start_y -= 1
		end

		while @stop_y < birds_by_y.length - 1 && birds_by_y[@stop_y + 1].position[1] - @position[1] < 10
			@stop_y += 1
		end

		near_birds_x = birds_by_x[@start_x..@stop_x]
		near_birds_y = birds_by_y[@start_y..@stop_y]
		near_birds = near_birds_x.intersection(near_birds_y)
		return if near_birds.count == 0# || @cached_near_birds == near_birds

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

		#if (@direction - new_direction).abs < 0.02
		#	@cached_near_birds = near_birds
		#end

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

		if @verbose
			@collision_square.x = @position[0] + 1.5
			@collision_square.y = @position[1] + 1.5

			@movement_vector.x1 = @position[0] + 1.5
			@movement_vector.y1 = @position[1] + 1.5

			@movement_vector.x2 = @position[0] + 1.5 + @velocity[0] * 10
			@movement_vector.y2 = @position[1] + 1.5 + @velocity[1] * 10
		end
	end
end
