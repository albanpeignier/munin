$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module Munin
  VERSION = '0.0.1'

  class Plugin

    class << self

      @@fields = []

      def graph_attributes(title, options = {})
        @@graph_options = { :title => title, :args => '--base 1000' }.merge(options)
      end

      def declare_field(name, options = {})
        @@fields << Field.new(name, options)
      end

      def with_options(options)
        yield OptionMerger.new(self, options)
      end

    end

    def initialize(config = {})
      @config = config.symbolize_keys

      if self.class.respond_to?(:config_from_filename)
        @config.merge!(self.class.config_from_filename.symbolize_keys)
      end

      after_initialize if respond_to?(:after_initialize)
    end

    def print_config
      output 'host_name', hostname unless hostname.nil?

      GRAPH_ATTRIBUTES.each do |graph_attribute|
        graph_option = @@graph_options[graph_attribute.to_sym]
        output "graph_#{graph_attribute}", graph_option unless graph_option.nil?
      end

      fields.each do |field|
        field.config.each_pair { |key, value| output key, value }
      end
    end

    def print_values
      retrieve_values.each_pair do |name, value|
        output "#{name}.value", value
      end
    end

    def run
      case ARGV.first
        when "config"
          print_config
        else
          print_values
      end
    end

    def fields
      @@fields
    end

    protected

    attr_accessor :hostname

    def output(key, value)
      puts "#{key} #{value}"
    end

    def config_value(key)
      @config[key]
    end

    GRAPH_ATTRIBUTES = %w{ title args category info order vlabel total scale period vtitle width height printf }

    private

    def method_missing(method, *arguments, &block)
      case method.id2name
        when /^graph_([_a-z]+)$/
          @@graph_options[$1.to_sym]
        when /^graph_([_a-z]+)=$/
          @@graph_options[$1.to_sym] = arguments
        else super
      end
    end

  end

  class Field

    attr_reader :name

    def initialize(name, options = {})
      @name, @options = name.to_s, options

      @options[:label] ||= default_label(name)
    end

    def default_label(name)
      name.to_s.gsub('_',' ')
    end

    def option(key)
      @options[key]
    end

    DATA_SOURCE_ATTRIBUTES = %w{ label cdef draw graph extinfo max min negative type warning critical colour skipdraw sum stack line }

    def config
      DATA_SOURCE_ATTRIBUTES.inject({}) do |config, attribute|
        attribute = attribute.to_sym
        attribute_value = @options[attribute]

        unless attribute_value.nil?
          case attribute
            when :type
              attribute_value = attribute_value.to_s.upcase
          end
          config["#{name}.#{attribute}"] = attribute_value
        end

        config
      end
    end

  end

  class OptionMerger # from ActiveSupport
    instance_methods.each do |method|
      undef_method(method) if method !~ /^(__|instance_eval|class|object_id)/
    end

    def initialize(context, options)
      @context, @options = context, options
    end

    private
      def method_missing(method, *arguments, &block)
        merge_argument_options! arguments
        @context.send(method, *arguments, &block)
      end

      def merge_argument_options!(arguments)
        arguments << if arguments.last.respond_to? :to_hash
          @options.merge(arguments.pop)
        else
          @options.dup
        end
      end
  end

  module Hash
    module Keys
      # Return a new hash with all keys converted to strings.
      def stringify_keys
        inject({}) do |options, (key, value)|
          options[key.to_s] = value
          options
        end
      end

      # Destructively convert all keys to strings.
      def stringify_keys!
        keys.each do |key|
          unless key.class.to_s == "String" # weird hack to make the tests run when string_ext_test.rb is also running
            self[key.to_s] = self[key]
            delete(key)
          end
        end
        self
      end

      # Return a new hash with all keys converted to symbols.
      def symbolize_keys
        inject({}) do |options, (key, value)|
          options[key.to_sym || key] = value
          options
        end
      end

      # Destructively convert all keys to symbols.
      def symbolize_keys!
        self.replace(self.symbolize_keys)
      end

      alias_method :to_options,  :symbolize_keys
      alias_method :to_options!, :symbolize_keys!

      # Validate all keys in a hash match *valid keys, raising ArgumentError on a mismatch.
      # Note that keys are NOT treated indifferently, meaning if you use strings for keys but assert symbol
      # as keys, this will fail.
      # examples:
      #   { :name => "Rob", :years => "28" }.assert_valid_keys(:name, :age) # => raises "ArgumentError: Unknown key(s): years"
      #   { :name => "Rob", :age => "28" }.assert_valid_keys("name", "age") # => raises "ArgumentError: Unknown key(s): years, name"
      #   { :name => "Rob", :age => "28" }.assert_valid_keys(:name, :age) # => passes, raises nothing
      def assert_valid_keys(*valid_keys)
        unknown_keys = keys - [valid_keys].flatten
        raise(ArgumentError, "Unknown key(s): #{unknown_keys.join(", ")}") unless unknown_keys.empty?
      end
    end
  end

end

class Hash #:nodoc:
  include Munin::Hash::Keys
end
