require "benchmark/ips"
require "active_record"

$LOAD_PATH << "./spec"

require "database"
require "models"

RespondToFaster::Test::Database.connect
RespondToFaster::Test::Database.auto_migrate

def progress_bar(int); print "." if (int % 100).zero? ; end

TIME    = (ENV["BENCHMARK_TIME"] || 20).to_i
RECORDS = (ENV["BENCHMARK_RECORDS"] || TIME * 100).to_i

puts "Inserting #{RECORDS} records..."
RECORDS.times do |record|
  Post.create(
    created_at: Date.today,
    title: "title #{record}",
    content: "content #{record}"
  )

  progress_bar(record)
end
puts "Done!\n"

def benchmark(time)
  Benchmark.ips(time) do |x|
    one_col    = Post.select("title as foo").to_a
    two_cols   = Post.select("title as foo, subtitle as bar").to_a
    three_cols = Post.select("title as foo, subtitle as bar, content as baz").to_a

    x.report("selecting one column") do
      one_col.map { |obj| obj.foo }
    end

    x.report("selecting two columns") do
      two_cols.map { |obj| obj.foo; obj.bar }
    end

    x.report("selecting three columns") do
      three_cols.map { |obj| obj.foo; obj.bar; obj.baz }
    end
  end
end

puts "\n\n\nBEFORE\n"
benchmark(TIME)

puts "\n\n\nAFTER\n"
require "respond_to_faster"
benchmark(TIME)
