#! /usr/bin/env ruby

require "optparse"
require "ruby2d"
require "matrix"
require "./bird.rb"

# Set up window basics
set title: "Birds", width: 800, height: 600, background: "white"

# Used as a timer (60 = 1 second)
tick = 0

# The list of BIRDS and a starting general direction
birds = []
direction = Vector[rand(-1.0..1.0), rand(-1.0..1.0)]

# Process command-line arguments.
options = {}
OptionParser.new do |opts|
	opts.banner = "Usage: main.rb [options]"

	opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
		options[:verbose] = v
	end
end.parse!

# Populate birds
5.times do
	birds << Bird.new(Vector[rand(800), rand(600)], direction)
end

update do
	clear

	if tick % 10 == 0
		# Decide new velocities
		new_velocities = []
		birds.each do |b|
			# Find birds within 30 of this bird.
			near_birds = birds.select do |i|
				Math.sqrt((b.position[0] - i.position[0]) ** 2 + (b.position[1] - i.position[1]) ** 2) < 5
			end

			if near_birds.count > 0
				new_velocities << Vector[near_birds.sum { |i| i.velocity[0] } / near_birds.count, near_birds.sum { |i| i.velocity[1] } / near_birds.count]
			else
				new_velocities << b.velocity
			end
		end

		# Set new velocities
        birds.each_with_index do |b, i|
            b.velocity = new_velocities[i]
        end

		# Update BIRDS
		birds.each do |b|
			b.update
		end
	end

	birds.each do |b|
        if options[:verbose]
            b.circle
        end

		b.square
	end

	tick += 1
end

show
