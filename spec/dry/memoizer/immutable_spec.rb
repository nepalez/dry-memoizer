describe Dry::Memoizer::Immutable do
  describe '#let' do
    it "works" do
      class Test::Person
        extend Dry::Initializer
        extend Dry::Memoizer::Immutable

        param :first_name
        param :last_name

        let(:full_name) { "#{first_name} #{last_name}" }
      end

      Test::User = Class.new(Test::Person)

      expect(Test::User.lets.to_a).to eql [:full_name]

      user = IceNine.deep_freeze(Test::User.new "Joe", "Doe")

      expect(user.instance_variable_get :@full_name).to eql "Joe Doe"

      expect(user.full_name).to eql "Joe Doe"
    end
  end
end
