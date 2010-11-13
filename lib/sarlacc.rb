require 'feedzirra'

class Sarlacc
  attr_reader :url

  USER_AGENT = "Sarlacc/0.1"

  def initialize(url, &block)
    @url = url
    @feed = nil
    @callback = block if block_given?
  end

  def consume
    if @feed
      on_success = lambda do |feed|
        DaemonKit.logger.debug("Feed at #{feed.url} has #{feed.new_entries.count} new entries")
        feed.new_entries.each {|entry| @callback.call(feed, entry)} if @callback
        @feed = feed
      end
      on_failure = lambda do |feed, code, header, body|
        DaemonKit.logger.warn("Request for feed at #{feed.url} failed with status #{code}")
      end
      Feedzirra::Feed.update(@feed, :on_success => on_success, :on_failure => on_failure)
    else
      on_success = lambda do |url, feed|
        DaemonKit.logger.debug("Feed at #{url} has #{feed.entries.count} entries")
        feed.entries.each {|entry| @callback.call(feed, entry)} if @callback
        @feed = feed
      end
      on_failure = lambda do |url, code, header, body|
        DaemonKit.logger.warn("Request for feed at #{url} failed with status #{code}")
      end
      Feedzirra::Feed.fetch_and_parse(@url, :on_success => on_success, :on_failure => on_failure,
        :user_agent => USER_AGENT)
    end
  end
end
