require 'feedzirra'

module Sarlacc
  class Fetcher
    def initialize(source, options = {})
      raise ArgumentError unless source.is_a?(Sarlacc::Source)
      @source = source
      @feed = nil
      @on_fetch = []
      @on_update = []
      @user_agent = options[:user_agent]
    end

    def fetch
      on_success = lambda do |url, feed|
        Sarlacc.logger.debug("Feed at #{url} has #{feed.entries.count} entries") if Sarlacc.logger
        @source.on_fetch(feed)
        @feed = feed
      end
      on_failure = lambda do |url, code, header, body|
        Sarlacc.logger.warn("Request for feed at #{url} failed with status #{code}") if Sarlacc.logger
      end
      Feedzirra::Feed.fetch_and_parse(@source.source_url, :on_success => on_success, :on_failure => on_failure,
        :user_agent => @user_agent)
      nil
    end

    def update
      raise NotFetchedError, "Feed was never fetched successfully" unless @feed
      on_success = lambda do |feed|
        Sarlacc.logger.debug("Feed at #{feed.url} has #{feed.new_entries.count} new entries") if Sarlacc.logger
        @source.on_update(feed)
        @feed = feed
      end
      on_failure = lambda do |feed, code, header, body|
        Sarlacc.logger.warn("Request for feed at #{feed.url} failed with status #{code}") if Sarlacc.logger
      end
      Feedzirra::Feed.update(@feed, :on_success => on_success, :on_failure => on_failure)
      nil
    end
  end

  class NotFetchedError < Exception; end
end
