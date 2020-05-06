#! /usr/bin/env ruby

require "optparse"
require "ruby2d"
require "matrix"
require "./bird.rb"

# Set up window basics
set title: "Birds", width: 800, height: 600, background: "white"

# Used as a timer (60 = 1 second)
tick = 0

# The list of BIRDS
birds = []
birds_by_x = []
birds_by_y = []

# Process command-line arguments.
options = {}
OptionParser.new do |opts|
	opts.banner = "Usage: main.rb [options]"

	opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
		options[:verbose] = v
	end
end.parse!

# Populate birds
400.times do
	birds << Bird.new(Vector[rand(800), rand(600)])
end

birds_by_x = birds.sort { |a, b| a.position[0] <=> b.position[0] }
birds_by_y = birds.sort { |a, b| a.position[1] <=> b.position[1] }

update do
	clear

	if tick % 1 == 0
		# Decide new directions
		new_directions = []

		birds.each_with_index do |b, j|
			# Find birds within a set distance of this bird.
			near_birds = birds.select do |i|
				Math.sqrt(((b.position[0] - i.position[0]) ** 2) + ((b.position[1] - i.position[1]) ** 2)) < 5 && b != i
			end

			if near_birds.count > 0
				if options[:verbose]
					puts "My direction: #{b.direction}"
				end

				new_directions << [j, (0.8 * b.direction) + (0.2 * (near_birds.sum { |d| d.direction } / near_birds.count))]

				if options[:verbose]
					puts "New direction: #{new_directions.last.last}"
				end
			end
		end

		# Set new velocities
		new_directions.each do |d|
			birds[d[0]].direction = d[1]
		end

		# Update BIRDS
		birds.each do |b|
			b.update
		end
	end

	birds.each do |b|
        if options[:verbose]
            b.collision_square
						b.movement_vector
        end

		b.square
	end

	tick += 1
end

show
