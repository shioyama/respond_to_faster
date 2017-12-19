RSpec.describe RespondToFaster do
  before { 2.times { Post.create } }

  context "select" do
    it "defines methods for all values returned from query" do
      post = Post.select("title as foo, content as bar").first

      aggregate_failures do
        expect(post).to have_method(:foo)
        expect(post).to have_method(:bar)
      end
    end
  end
end
