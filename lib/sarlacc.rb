require 'em-http'
require 'feedzirra'

class Sarlacc
  attr_reader :url

  def initialize(url)
    @url = url
    @callback = nil
    listen
  end

  def onfeed(&block)
    @callback = block
  end

private
  def listen
    request = EventMachine::HttpRequest.new(@url).get

    request.callback do
      if request.response_header.status == 200
        begin
          feed = Feedzirra::Feed.parse(request.response)
          @callback.call(feed)
        rescue Exception => e
          puts "Error parsing feed at #{@url}: #{@e.message}"
        end
      else
        puts "Request for feed at #{@url} failed with status #{request.response_header.status}"
      end
    end

    request.errback do |request|
      puts "Error fetching feed at #{@url}: #{request.error}"
    end
  end
end
