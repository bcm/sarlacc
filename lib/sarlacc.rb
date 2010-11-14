require 'active_support/core_ext/class/attribute_accessors'
require 'feedzirra'

class Sarlacc
  cattr_accessor :logger, :instance_writer => false
  cattr_accessor :user_agent, :instance_writer => false

  attr_reader :url, :feed

  def initialize(url)
    @url = url
    @feed = nil
    @callback = nil
  end

  def on_entry(&block)
    @callback = block
  end

  def consume
    if @feed
      on_success = lambda do |feed|
        logger.debug("Feed at #{feed.url} has #{feed.new_entries.count} new entries") if logger
        feed.new_entries.each {|entry| @callback.call(feed, entry)} if @callback
        @feed = feed
      end
      on_failure = lambda do |feed, code, header, body|
        logger.warn("Request for feed at #{feed.url} failed with status #{code}") if logger
      end
      Feedzirra::Feed.update(@feed, :on_success => on_success, :on_failure => on_failure)
    else
      on_success = lambda do |url, feed|
        logger.debug("Feed at #{url} has #{feed.entries.count} entries") if logger
        feed.entries.each {|entry| @callback.call(feed, entry)} if @callback
        @feed = feed
      end
      on_failure = lambda do |url, code, header, body|
        logger.warn("Request for feed at #{url} failed with status #{code}") if logger
      end
      Feedzirra::Feed.fetch_and_parse(@url, :on_success => on_success, :on_failure => on_failure,
        :user_agent => user_agent)
    end
  end
end
