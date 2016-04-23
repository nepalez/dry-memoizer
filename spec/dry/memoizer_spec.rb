describe Dry::Memoizer do
  describe "#let" do
    it "works" do
      class Test::Person
        extend Dry::Initializer
        extend Dry::Memoizer

        param :first_name
        param :last_name

        let(:full_name) { "#{first_name} #{last_name}" }
      end

      Test::User = Class.new(Test::Person)

      user = Test::User.new "Joe", "Doe"

      expect { user.full_name }
        .to change { user.instance_variable_get :@full_name }
        .from(nil)
        .to "Joe Doe"

      expect(user.full_name).to eql "Joe Doe"
    end
  end

  describe ".immutable" do
    it "when not specified returns Dry::Memoizer::Immutable" do
      expect(described_class.immutable).to eql described_class::Immutable
    end

    it "with true returns Dry::Memoizer::Immutable" do
      expect(described_class.immutable(true)).to eql described_class::Immutable
    end

    it "with false returns Dry::Memoizer" do
      expect(described_class.immutable(false)).to eql described_class
    end
  end
end
