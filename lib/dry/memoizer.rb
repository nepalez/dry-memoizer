module Dry
  module Memoizer
    # Defines memoized method with given name and block
    #
    # @example
    #   class User
    #     extend Dry::Initializer
    #     extend Dry::Memoizer
    #
    #     param :first_name
    #     param :last_name
    #
    #     let(:full_name) { "#{first_name} #{last_name}" }
    #   end
    #
    #   joe = User.new('Joe', 'Doe')
    #   joe.instance_variable_get :@full_name # => nil
    #
    #   joe.full_name # => 'Joe Doe'
    #   joe.instance_variable_get :@full_name # => 'Joe Doe'
    #
    # @param  [#to_sym] name
    # @param  [Proc]    block
    # @return [self]
    #
    # @api public
    def let(name, &block)
      key  = name.to_sym
      ivar = :"@#{name}"

      define_method(key) do
        @__let__ ||= []
        return instance_variable_get(ivar) if @__let__.include? key

        value = instance_exec(&block)
        @__let__ << key
        instance_variable_set(ivar, value)
      end

      lets << key
      self
    end

    # Returns the set of memoized methods' names
    #
    # @return [Set<Symbol>]
    #
    # @api public
    def lets
      @lets ||= Set.new
    end

    # @private
    def inherited(klass)
      klass.instance_variable_set(:@lets, @lets)
      super
    end
  end
end
