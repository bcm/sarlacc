module Sarlacc
  module Source
    def source_url
      raise UnimplementedError
    end

    def emit_fetch_event(feed)
      Sarlacc.logger.debug("Feed at #{url} has #{feed.entries.count} entries") if Sarlacc.logger
      feed.entries.each do |entry|
         Sarlacc.logger.info("'#{entry.title}' published at #{entry.published}") if Sarlacc.logger
       end
      FetchEvent.new(self, feed, feed.entries)
    end

    def emit_update_event(feed)
      Sarlacc.logger.debug("Feed at #{feed.url} has #{feed.new_entries.count} new entries") if Sarlacc.logger
      feed.new_entries.each do |entry|
        Sarlacc.logger.info("'#{entry.title}' published at #{entry.published}") if Sarlacc.logger
      end
      FetchEvent.new(self, feed, feed.new_entries)
    end
  end

  class FetchEvent
    attr_reader :source, :feed, :entries

    def initialize(source, feed, entries)
      @source = source
      @feed = feed
      @entries = entries
    end

    def process
      raise NotImplementedError
    end
  end
end
