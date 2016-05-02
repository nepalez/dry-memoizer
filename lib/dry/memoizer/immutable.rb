module Dry::Memoizer
  module Immutable
    include Dry::Memoizer

    # Adds execution of the variable to the initializer
    #
    # @example
    #   class User
    #     extend Dry::Initializer
    #     extend Dry::Memoizer::Immutable
    #
    #     param :first_name
    #     param :last_name
    #
    #     let!(:full_name) { "#{first_name} #{last_name}" }
    #   end
    #
    #   joe = User.new('Joe', 'Doe')
    #   joe.instance_variable_get :@full_name # => 'Joe Doe'
    #   joe.full_name # => 'Joe Doe'
    #
    # @param  [#to_sym] name
    # @param  [Proc]    block
    # @return [self]
    #
    def let(name, &block)
      @__let__[name.to_sym] = block
      attr_reader name

      lets << name
      self
    end

    # @private
    def inherited(klass)
      super
      klass.instance_variable_set :@__let__, @__let__
    end

    # @private
    def self.extended(klass)
      klass.instance_variable_set :@__let__, {}

      klass.send :define_method, :initialize do |*args|
        super(*args)
        self.class.instance_variable_get(:@__let__).each do |name, block|
          instance_variable_set :"@#{name}", instance_eval(&block)
        end
      end
    end
  end

  # Switches between versions of the module
  #
  # @param  [Boolean] flag Whether to use immutable version of the module
  # @return [Module] Either [Dry::Memoizer] or [Dry::Memoizer::Immutable]
  #
  def self.immutable(flag = true)
    flag ? Immutable : self
  end
end
