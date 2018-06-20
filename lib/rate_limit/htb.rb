require "rate_limit/htb/version"

module RateLimit
  # Htb is a ruby implementation of the hierarchical token bucket algorithm.
  #
  # It allows you to do rate limiting in a hierarchical fashion in other words you can put a large rate at the root of
  # and smaller rates as children. This way you can guarantee your children a minimum rate and a maximum rate up to the
  # rate of the parents. The rate is represented by Tokens you take out of buckets.
  #
  # The sum of the rates of the children on the same level may not be greater than the rate of their parent or they will
  # exceed the the rate of their parent.
  #
  # =Example
  #   root = RateLimit::Htb::Bucket.new 1000
  #   child1 = RateLimit::Htb::Bucket.new 300, root
  #   child2 = RateLimit::Htb::Bucket.new 600, root
  #
  #   threads = []
  #
  #   # prints stuff twice as fast as the other two
  #   threads << Thread.new do
  #     100.times do
  #       child1.blocking_take 200
  #       puts "stuff"
  #     end
  #   end
  #
  #   threads << Thread.new do
  #     100.times do
  #       child2.blocking_take 400
  #       puts "stuff2"
  #     end
  #   end
  #
  #   # Is called rarely because the other thread needs all the tokens.
  #   threads << Thread.new do
  #     100.times do
  #       child2.blocking_take 400
  #       puts "stuff3"
  #     end
  #   end
  #
  #   threads.each { |t| t.join }
  module Htb
    class Bucket

      # ==== Attributes
      #
      # * +rate+ - Amount of tokens generated every second.
      # * +parent+ - Parent of this bucket. Any tokens taken from this bucket will also be taken from parent. When a
      #   parent is specified the rate of this bucket will be between the rate of this bucket and the rate of the parent.
      #   The parent bucket should have a larger rate than their children.
      #
      def initialize(rate, parent = nil)
        @lock = Monitor.new
        @rate = rate
        @bucket_size = rate
        @parent = parent
        @tokens = rate
        @last_update_timestamp = Time.now
      end

      # Take the specified amount of tokens from this bucket
      #
      # If you want your code to block execution until it could take the specified amount of tokens use #blocking_take
      # instead.
      #
      # * *Returns* :
      #   - true if the amount of tokens could be taken from this bucket or a parent.
      def take(amount)
        @lock.synchronize do
          replenish

          could_take = can_take? amount
          account amount if could_take

          could_take
        end
      end


      # This method takes the specified amount of tokens from the bucket and blocks execution until it was successful.
      #
      # This method tries to be smart about the amount of time it waits. It will wait the minimum time it takes to
      # replenish enough tokens.
      def blocking_take(amount)
        # Try to take amount tokens from this bucket or wait for the tokens to replenish
        # do this until we could get the amount of tokens we wanted
        until take amount
          duration = amount.to_f / @rate
          puts "sleeping for #{duration}"
          sleep duration
        end
      end

      protected

      def replenish(timestamp = Time.now)
        @lock.synchronize do
          @parent.replenish timestamp if @parent

          elapsed = timestamp - @last_update_timestamp
          @tokens = [@bucket_size, @tokens + @rate * elapsed].min

          @last_update_timestamp = timestamp
        end
      end

      def can_take?(amount)
        @tokens >= amount || (@parent && @parent.can_take?(amount))
      end

      def account(amount)
        @lock.synchronize do
          @tokens = @tokens - amount
          @parent.account amount if @parent
        end
      end

      def rate
        return @rate if @rate != 0
        return @parent.rate if @parent

        raise 'NO Bucket in this hierachie has a Limit other than zero!!'
      end
    end
  end
end
