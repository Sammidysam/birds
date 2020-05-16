#! /usr/bin/env ruby

require "optparse"
require "ruby2d"
require "rubystats"
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
1000.times do |i|
	birds << Bird.new(i, Vector[rand(800), rand(600)], rand(-Math::PI..Math::PI), rand(), options[:verbose])
end

puts "Average strength: #{birds.sum { |b| b.strength }.fdiv(1000)}"

birds_by_x = birds.sort_by { |b| b.position[0] }
birds_by_y = birds.sort_by { |b| b.position[1] }

birds.each do |b|
	b.seed_start_stop(birds_by_x, birds_by_y)
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
	print "\rTick: #{tick}"

	if tick % 10 == 0
		birds_by_x = birds.sort_by { |b| b.position[0] }
		birds_by_y = birds.sort_by { |b| b.position[1] }

		birds.each do |b|
			b.react_to_birds(birds_by_x, birds_by_y)
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
