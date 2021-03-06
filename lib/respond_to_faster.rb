require "active_record"
require "respond_to_faster/version"

module RespondToFaster
  def find_by_sql(sql, binds = [], preparable: nil, &block)
    super.tap do |records|
      record = records.first
      unless record.nil? || (uncached_attrs = record.attribute_names - attribute_names).empty?
        uncached_attrs.each &record.singleton_class.method(:define_method_attribute)
        mod = record.singleton_class.send(:generated_attribute_methods)
        records[1..-1].each { |record| record.singleton_class.include mod }
      end
    end
  end
end

ActiveRecord::Base.extend RespondToFaster
