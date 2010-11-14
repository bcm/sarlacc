require 'active_support/core_ext/class/attribute_accessors'
require 'feedzirra'

class Sarlacc
  cattr_accessor :logger, :instance_writer => false

  def initialize(url, options = {})
    @url = url
    @feed = nil
    @on_fetch = []
    @on_update = []
    @user_agent = options[:user_agent]
  end

  def on_fetch(&block)
    @on_fetch << block
  end

  def on_update(&block)
    @on_update << block
  end

  def fetch
    on_success = lambda do |url, feed|
      logger.debug("Feed at #{url} has #{feed.entries.count} entries") if logger
      @on_fetch.each {|proc| proc.call(feed)}
      @feed = feed
    end
    on_failure = lambda do |url, code, header, body|
      logger.warn("Request for feed at #{url} failed with status #{code}") if logger
    end
    Feedzirra::Feed.fetch_and_parse(@url, :on_success => on_success, :on_failure => on_failure,
      :user_agent => @user_agent)
    nil
  end

  def update
    raise NotFetchedError, "Feed was never fetched successfully" unless @feed
    on_success = lambda do |feed|
      logger.debug("Feed at #{feed.url} has #{feed.new_entries.count} new entries") if logger
      @on_update.each {|proc| proc.call(feed)}
      @feed = feed
    end
    on_failure = lambda do |feed, code, header, body|
      logger.warn("Request for feed at #{feed.url} failed with status #{code}") if logger
    end
    Feedzirra::Feed.update(@feed, :on_success => on_success, :on_failure => on_failure)
    nil
  end
end

class NotFetchedError < Exception; end
