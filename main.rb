#! /usr/bin/env ruby

require "optparse"
require "ruby2d"
require "matrix"

require "./bird.rb"

# Set up window basics
set title: "Birds", width: 800, height: 600, background: "white"

# Used as a timer (60 = 1 second)
tick = 0

# Whether we will do work or not
paused = false

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
100.times do
	birds << Bird.new(Vector[rand(800), rand(600)], rand(0..2*Math::PI), options[:verbose])
end

on :key_down do |event|
	if event.key == "space"
		paused = !paused
	elsif event.key == "escape"
		exit
	end
end

update do
	next if paused

	if tick % 1 == 0
		# Decide new directions
		new_directions = []

		birds.each_with_index do |b, j|
			# Find birds within a set distance of this bird.
			near_birds = birds.select do |i|
				Math.sqrt(((b.get_position[0] - i.get_position[0]) ** 2) + ((b.get_position[1] - i.get_position[1]) ** 2)) < 10 && b != i
			end

			if near_birds.count > 0
				new_directions << [j, (0.8 * b.velocity) + (0.2 * (near_birds.inject(Vector[0, 0]) { |sum, d| sum + d.velocity } / near_birds.count))]
			end
		end

		# Set new velocities
		new_directions.each do |d|
			birds[d[0]].set_velocity d[1]
		end

		# Update BIRDS
		birds.each do |b|
			b.update
		end
	end

	tick += 1
end

show
