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
    # @return [nil]
    #
    def let(name, &block)
      ivar = :"@#{name}"

      define_method(name) do
        key = name.to_sym

        @__let__ ||= {}
        return instance_variable_get(ivar) if @__let__[key]

        value = instance_exec(&block)
        @__let__[key] = true
        instance_variable_set(ivar, value)
      end

      nil
    end
  end
end
