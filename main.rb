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
200.times do
	birds << Bird.new(Vector[rand(800), rand(600)], rand(-Math::PI..Math::PI), rand(), options[:verbose])
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

	if tick % 10 == 0
		birds.each_with_index do |b, j|
			# Find birds within a set distance of this bird.
			near_birds = birds.select.with_index do |i, k|
				j != k && b.distance_to(i) < 10
			end

			b.react_to_birds near_birds
			b.stay_in_bounds
		end
	end

	# Update BIRDS
	birds.each do |b|
		b.update
	end

	tick += 1
end

show
