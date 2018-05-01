require 'csv'

module Julia
  class Builder
    attr_reader :collection, :csv_options

    def initialize(collection, csv_options = Hash.new)
      @collection, @csv_options = collection, csv_options
    end

    def self.column(keyname, action = nil, &block)
      if model_class.respond_to?(:human_attribute_name)
        translated_key = model_class.human_attribute_name(keyname)
      end

      columns[translated_key || keyname] = Action.new(keyname, action, &block)
    end

    def self.columns
      @columns ||= {}
    end

    def self.model_class
      @model_class ||= name.demodulize.sub(/Csv$/, '').constantize
    rescue NameError
    end

    def self.inherited(subclass)
      columns.each do |key, action|
        subclass.column(key, action.action, &action.block)
      end
    end

    def build
      CSV.generate(csv_options) do |csv|
        csv << columns.keys
        yield(csv) if block_given?
        collection.each_with_index do |record, i|
          csv << columns.values.map do |action|
            action.get_value(record, i)
          end
        end
      end&.force_encoding('utf-8')
    end

    protected

    def columns
      self.class.columns
    end
  end
end
