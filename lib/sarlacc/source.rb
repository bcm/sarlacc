module Sarlacc
  module Source
    def source_url
      raise UnimplementedError
    end

    def on_fetch(feed)
    end

    def on_update(feed)
    end
  end
end
