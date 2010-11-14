require 'feedzirra'

module Sarlacc
  class Fetcher
    def initialize(source, options = {})
      raise ArgumentError unless source.is_a?(Sarlacc::Source)
      @source = source
      @feed = nil
      @user_agent = options[:user_agent]
      @queue = Queue.new
    end

    def fetch
      if @feed
        on_success = lambda do |feed|
          @queue << @source.emit_update_event(feed)
        end
        on_failure = lambda do |feed, code, header, body|
          Sarlacc.logger.warn("Request for feed at #{feed.url} failed with status #{code}") if Sarlacc.logger
        end
        Feedzirra::Feed.update(@feed, :on_success => on_success, :on_failure => on_failure)
      else
        on_success = lambda do |url, feed|
          @queue << @source.emit_fetch_event(feed)
          @feed = feed
        end
        on_failure = lambda do |url, code, header, body|
          Sarlacc.logger.warn("Request for feed at #{url} failed with status #{code}") if Sarlacc.logger
        end
        Feedzirra::Feed.fetch_and_parse(@source.source_url, :on_success => on_success, :on_failure => on_failure,
          :user_agent => @user_agent)
      end
    end

    def process
      while (! @queue.empty?) do
        @queue.pop.process
      end
    end

    def fetch_and_process
      fetch
      process
    end
  end
end
