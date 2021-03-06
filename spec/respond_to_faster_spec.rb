RSpec.describe RespondToFaster do
  before do
    2.times do |i|
      Post.create(title: "title #{i}",
                  content: "content #{i}")
    end
  end

  pending "removes respond_to? override" do
    expect(ActiveModel::AttributeMethods.instance_methods).not_to include(:respond_to?)
  end

  pending "removes method_missing override" do
    expect(ActiveModel::AttributeMethods.instance_methods).not_to include(:method_missing)
  end

  describe ".find_by" do
    it "works like normal" do
      expect(Post.find_by(title: "title 1")).to eq(Post.last)
    end
  end

  describe ".select" do
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

    it "never calls method_missing" do
      post = posts.first
      expect(post).not_to receive(:method_missing)
      post.foo
    end

    it "works with no results in result set" do
      expect {
        expect(Post.select("title as foo").where(title: "baz").to_a).to eq([])
      }.not_to raise_error
    end
  end

  describe ".select on association" do
    let(:post) { Post.first }
    let(:comments) { post.comments.select("content as foo, author_id as bar") }
    before do
      post.comments.create(content: "foocontent", author_id: 3)
    end

    it "returns correct values" do
      expect(comments.map { |c| [c.foo, c.bar] }).to eq([["foocontent", 3]])
    end

    it "defines methods for all values returned from query" do
      aggregate_failures do
        comments.each do |comment|
          expect(comment).to have_method(:foo)
          expect(comment).to have_method(:bar)
        end
      end
    end

    it "never calls method_missing" do
      comment = comments.first
      expect(comment).not_to receive(:method_missing)
      comment.foo
    end
  end

  describe "#respond_to?" do
    context "model initialized" do
      let(:post) { Post.new }

      it "returns true if attribute is defined" do
        expect(post.respond_to?(:title)).to eq(true)
      end

      it "returns false if attribute is not defined" do
        expect(post.respond_to?(:xyz)).to eq(false)
      end
    end

    context "result returned from custom query" do
      let(:post) { Post.select("title as foo, content as bar").first }

      it "returns true if attribute is a value returned from query" do
        expect(post.respond_to?(:foo)).to eq(true)
      end

      it "returns false if attribute is a value returned from query" do
        expect(post.respond_to?(:title)).to eq(false)
      end

      it "does not call method_missing" do
        expect(post).not_to receive(:method_missing)
        post.foo
      end
    end
  end

  describe "ancestors of singleton classes" do
    it "has only one extra ancestor" do
      initialized_post = Post.new
      posts = Post.select("title as foo")
      first_post = posts.first
      last_post = posts.last

      aggregate_failures "ancestors compared with class ancestors" do
        expect(first_post.singleton_class.ancestors.size).to eq(Post.ancestors.size + 2)
        expect(last_post.singleton_class.ancestors.size).to eq(Post.ancestors.size + 2)
      end

      aggregate_failures "ancestors compared with initialized model" do
        expect(first_post.singleton_class.ancestors.size).to eq(initialized_post.singleton_class.ancestors.size + 1)
        expect(last_post.singleton_class.ancestors.size).to eq(initialized_post.singleton_class.ancestors.size + 1)
      end
    end
  end

  describe "#init_with" do
    it "works with virtual attributes" do
      post = Post.select("title as foo").first
      dumped = YAML.load(YAML.dump(post))

      expect(post.foo).to eq("title 0")
      expect(dumped.foo).to eq("title 0")
    end
  end
end
