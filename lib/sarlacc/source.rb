module Sarlacc
  module Source
    def source_url
      raise UnimplementedError
    end

    def emit_fetch_event(feed)
      FetchEvent.new(self, feed, feed.entries)
    end

    def emit_update_event(feed)
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
