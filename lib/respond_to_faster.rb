require "respond_to_faster/version"

module RespondToFaster
  def init_with(coder)
    super.tap do
      (attribute_names - self.class.attribute_names).each do |name|
        singleton_class.define_attribute_method name
      end
    end
  end
end

ActiveRecord::Base.include RespondToFaster
ActiveModel::AttributeMethods.send(:remove_method, :respond_to?)
ActiveModel::AttributeMethods.send(:remove_method, :method_missing)
