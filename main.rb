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

# Process command-line arguments.
options = {}
OptionParser.new do |opts|
	opts.banner = "Usage: main.rb [options]"

	opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
		options[:verbose] = v
	end
end.parse!

# Populate birds
700.times do
	birds << Bird.new(Vector[rand(800), rand(600)])
end

update do
	clear

	if tick % 2 == 0
		# Decide new directions
		new_directions = []

		birds.each do |b|
			# Find birds within a set distance of this bird.
			near_birds = birds.select do |i|
				Math.sqrt(((b.position[0] - i.position[0]) ** 2) + ((b.position[1] - i.position[1]) ** 2)) < 5 && b != i
			end

			if near_birds.count > 0
				if options[:verbose]
					puts "My velocity: #{b.velocity}"
				end

				new_directions << (0.8 * b.direction) + (0.2 * (near_birds.sum { |d| d.direction } / near_birds.count))

				if options[:verbose]
					puts "New velocity: #{new_velocities.last}"
				end
			else
				new_directions << b.direction
			end
		end

		# Set new velocities
        birds.each_with_index do |b, i|
            b.direction = new_directions[i]
        end

		# Update BIRDS
		birds.each do |b|
			b.update
		end
	end

	birds.each do |b|
        if options[:verbose]
            b.collision_square
        end

		b.square
	end

	tick += 1
end

show
