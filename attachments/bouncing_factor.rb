#!/usr/bin/env ruby

require 'bundler/setup'
require 'optparse'

Bundler.require

@title = "Bounce Factor Distribution"
@post_process = &:identity
@post_process_description = "per agent"
@ai_name = "ORCA"

parser = OptionParser.new do |opts|
  opts.banner = "Usage: bouncing_factor.rb [options] scene1 [scene2 ...]"
  opts.on("--title TITLE", "Title for the plot") do |title|
    @title = title
  end

  opts.on("--post METHOD", "Post processing method") do |method|
    case method
    when "identity"
      @post_process = &:identity
      @post_process_description = "per agent"
    when "max"
      @post_process = &:max
      @post_process_description = "maximal per run"
    when "avg"
      @post_process = ->(x) { x.sum / x.size }
      @post_process_description = "average per run"
    else
      raise ArgumentError, "Unknown post processing method: #{method}"
    end
  end

  opts.on("--ai AI", "AI name") do |ai|
    @ai_name = ai
  end

end


parser.parse!

files = Dir.glob("/home/kaidong/Desktop/coai/*.bin")

scenes = ARGV.map do |file|
  Steersuite.load(file)
end

def normalize(v)
  norm = Numpy.linalg.norm(v, axis: 0, keepdims: true)
  return v / norm
end

def compute_bounce_factor(sample)
  sample = Numpy.asarray(sample)
  grad = sample[1..-1] - sample[0..-2]
  destination = sample[-1]
  start = sample[0]
  dvec = normalize(destination - start)
  result = Numpy.dot(grad, dvec)
  Numpy.abs(result).sum / result.sum
end

bfs = scenes.flat_map do |scene|
  scene.agent_data.map do |sample|
    compute_bounce_factor(sample)
  end.then { _1.sum / _1.size }
end

@title = "Bounce Factor Distribution, #{@ai_name}, 100 runs, #{@post_process_description}"
Matplotlib.pyplot.hist(bfs, bins: 20)
Matplotlib.pyplot.title(@title)
Matplotlib.pyplot.xlabel("Bounce Factor")
Matplotlib.pyplot.ylabel("Frequency")
Matplotlib.pyplot.show()
