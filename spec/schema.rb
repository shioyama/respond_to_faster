module RespondToFaster
  module Test
    if ENV['RAILS_VERSION'] == '4.2'
      parent_class = ::ActiveRecord::Migration
    else
      parent_class = ::ActiveRecord::Migration[[::ActiveRecord::VERSION::MAJOR, ::ActiveRecord::VERSION::MINOR].join(".")]
    end

    class Schema < parent_class
      class << self
        def up
          create_table "posts" do |t|
            t.string :title
            t.text :content
            t.integer :author_id

            t.timestamps
          end

          create_table "comments" do |t|
            t.text :content
            t.integer :author_id
            t.integer :post_id

            t.timestamps
          end

          create_table "authors" do |t|
            t.string :name

            t.timestamps
          end
        end
      end
    end
  end
end
