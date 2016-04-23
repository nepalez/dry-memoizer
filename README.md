# dry-memoizer [![Join the chat at https://gitter.im/dry-rb/chat](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/dry-rb/chat)

[![Gem Version](https://badge.fury.io/rb/dry-memoizer.svg)][gem]
[![Build Status](https://travis-ci.org/dry-rb/dry-memoizer.svg?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/dry-rb/dry-memoizer.svg)][gemnasium]
[![Code Climate](https://codeclimate.com/github/dry-rb/dry-memoizer/badges/gpa.svg)][codeclimate]
[![Test Coverage](https://codeclimate.com/github/dry-rb/dry-memoizer/badges/coverage.svg)][coveralls]
[![Inline docs](http://inch-ci.org/github/dry-rb/dry-memoizer.svg?branch=master)][inchpages]

[gem]: https://rubygems.org/gems/dry-memoizer
[travis]: https://travis-ci.org/dry-rb/dry-memoizer
[gemnasium]: https://gemnasium.com/dry-rb/dry-memoizer
[codeclimate]: https://codeclimate.com/github/dry-rb/dry-memoizer
[coveralls]: https://coveralls.io/r/dry-rb/dry-memoizer
[inchpages]: http://inch-ci.org/github/dry-rb/dry-memoizer

This micro module defines class helper method `let` inspired by [RSpec][rspec].

[rspec]: http://rspec.info

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dry-memoizer'
```

And then execute:

```shell
$ bundle
```

Or install it yourself as:

```shell
$ gem install dry-memoizer
```

## Synopsis

### Dry::Memoizer

```ruby
require 'dry-initializer'
require 'dry-memoizer'

class User
  extend Dry::Initializer
  extend Dry::Memoizer

  param :first_name
  param :last_name, default: proc { nil }

  let(:full_name) { [first_name, last_name].compact.join('_') }
end

user = User.new 'Joe', 'Doe'
user.instance_variable_get :@full_name # => nil

user.full_name # => 'Joe Doe'
user.instance_variable_get :@full_name # => 'Joe Doe'
```

This is the same as:

```ruby
require 'dry-initializer'

class User
  extend Dry::Initializer

  param :first_name
  param :last_name

  def full_name
    @full_name ||= [first_name, last_name].compact.join('_')
  end
end
```

We prefer `let` to `def` in multi-step calculations:

```ruby
require 'dry-initializer'
require 'dry-memoizer'
require 'hashie/mash'

class CountPrice
  extend Dry::Initializer
  extend Dry::Memoizer::Mutable

  param :product
  param :count
  param :addons
  param :address

  let(:product_price)  { product.price * count }
  let(:discount)       { (count > 1) ? 0.1 : 0 }
  let(:discount_price) { product_price * discount }
  let(:addons_price)   { Array(addons).map(&:price).reduce(:+) }
  let(:delivery_price) { (address&.city == 'Moscow') ? 0 : 500 }
  let(:total_price)    { product_price - discount_price + addons_price + delivery_price }

  def call
    Hashie::Mash.new \
      product_price:  product_price,
      addons_price:   addons_price,
      delivery_price: delivery_price,
      discount_price: discount_price,
      total_price:    total_price
  end
end
```

### Dry::Memoizer.immutable

Using the same syntax, this module defines `let` helper differently.

Instead of providing a memoizer, it executes the block at the end of the initializer and assigns the result to corresponding attribute.

```ruby
require 'dry-initializer'
require 'dry-memoizer'
require 'dry-memoizer/immutable' # require this plugin explicitly

class User
  extend Dry::Initializer
  extend Dry::Memoizer.immutable(true)

  param :first_name
  param :last_name, default: proc { nil }

  let(:full_name) { [first_name, last_name].compact.join('_') }
end

# An instance is truly immutable and can be frozen
user = IceNine.deep_freeze(User.new 'Joe', 'Doe')

user.instance_variable_get :@full_name # => 'Joe Doe'
user.full_name # => 'Joe Doe'
```

This was the same as:

```ruby
require 'dry-initializer'

class User
  extend Dry::Initializer

  param :first_name
  param :last_name, default: proc { nil }

  def initialize(*)
    super
    @full_name = [first_name, last_name].compact.join('_')
  end

  attr_reader :full_name
end
```

Assigning all variables inside the initializer is not a best idea. You hardly need this in production.

Instead, switch between module versions depending on current environment:

```ruby
require 'dry-initializer'
require 'dry-memoizer'
require 'dry-memoizer/immutable'

class User
  extend Dry::Initializer
  extend Dry::Memoizer.immutable(ENV['ENV'] == 'test')

  param :first_name
  param :last_name, default: proc { nil }

  let(:full_name) { [first_name, last_name].compact.join('_') }
end
```

By selecting the module depending on current env you can:

* ensure in test env, that your instances are mutation-safe (can be frozen)
* use a much faster mutable version in production at the same time

```ruby
require 'rspec'

RSpec.describe User do
  # ENV['ENV'] is supposed to be set to 'test'
  let(:user) { IceNine.deep_freeze(User.new 'Joe', 'Doe') }

  # ... the rest of the test
end
```

When using this trick, notice that unlike true memoizers blocks are executed in the order of definition.

You should also notice the right order of extensions:

```ruby
extend Dry::Initializer        # rewrites the initializer
extend Dry::Memoizer.immutable # appends definitions to the existing initializer
```

## Compatibility

Tested under rubies [compatible to MRI 2.2+](.travis.yml).

## Contributing

* [Fork the project](https://github.com/dry-rb/dry-memoizer)
* Create your feature branch (`git checkout -b my-new-feature`)
* Add tests for it
* Commit your changes (`git commit -am '[UPDATE] Add some feature'`)
* Push to the branch (`git push origin my-new-feature`)
* Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
