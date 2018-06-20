# RateLimit::Htb

This is a Ruby implementation of the hierarchical Token bucket algorithm. It allows you to limit
the rate certain operations are executed. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rate_limit-htb'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rate_limit-htb

## Usage

```ruby
root = RateLimit::Htb::Bucket.new 1000
child1 = RateLimit::Htb::Bucket.new 300, root
child2 = RateLimit::Htb::Bucket.new 600, root

threads = []

# prints stuff twice as fast as the other two
threads << Thread.new do
  100.times do
    child1.blocking_take 200
    puts "stuff"
  end
end

threads << Thread.new do
  100.times do
    child2.blocking_take 400
    puts "stuff2"
  end
end

# Is called rarely because the other thread needs all the tokens.
threads << Thread.new do
  100.times do
    child2.blocking_take 400
    puts "stuff3"
  end
end

threads.each { |t| t.join }
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/HappyKadaver/rate_limit-htb.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
