RSpec.describe RespondToFaster do
  before do
    2.times do |i|
      Post.create(title: "title #{i}",
                  content: "content #{i}")
    end
  end

  context "select" do
    let(:posts) { Post.select("title as foo, content as bar") }

    it "returns correct values" do
      expect(posts.map { |p| [p.foo, p.bar] }).to match_array([["title 0", "content 0"], ["title 1", "content 1"]])
    end

    it "defines methods for all values returned from query" do
      aggregate_failures do
        posts.each do |post|
          expect(post).to have_method(:foo)
          expect(post).to have_method(:bar)
        end
      end
    end
  end
end
