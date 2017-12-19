require "active_record"
require "respond_to_faster/version"

module RespondToFaster
  def init_with(coder)
    super.tap do
      unless (uncached_attrs = attribute_names - self.class.attribute_names).empty?
        klass = self.class
        mod_name = "RespondToFaster_#{uncached_attrs.hash.abs}".freeze
        if klass.const_defined?(mod_name)
          singleton_class.include klass.const_get(mod_name)
        else
          uncached_attrs.each &singleton_class.method(:define_attribute_method)
          klass.const_set(mod_name, singleton_class.send(:generated_attribute_methods))
        end
      end
    end
  end
end

ActiveRecord::Base.include RespondToFaster
ActiveModel::AttributeMethods.send(:remove_method, :respond_to?)
ActiveModel::AttributeMethods.send(:remove_method, :method_missing)
