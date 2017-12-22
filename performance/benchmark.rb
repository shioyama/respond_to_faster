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
    post_by_select = Post.select("title as foo").first
    post_by_find   = Post.first

    x.report("select query accessor") do
      post_by_select.foo
    end

    x.report("find query accessor") do
      post_by_find.title
    end

    x.report("instantiating with select on two columns") do
      Post.select("title as foo, content as bar").to_a
    end

    x.report("instantiating with find") do
      Post.all.to_a
    end

    x.report("together - select on two columns") do
      Post.select("title as foo, content as bar").map { |p| p.foo; p.bar }
    end

    x.report("together - find") do
      Post.all.map { |p| p.title; p.content }
    end
  end
end

puts "\n\n\nBEFORE\n"
benchmark(TIME)

puts "\n\n\nAFTER\n"
require "respond_to_faster"
benchmark(TIME)
