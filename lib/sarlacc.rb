require 'em-http'
require 'feedzirra'

class Sarlacc
  attr_reader :url

  def initialize(url, options = {})
    @url = url
    @onfeed = options[:onfeed]
    @onentry = options[:onentry]
  end

  def consume
    request = EventMachine::HttpRequest.new(@url).get

    request.callback do
      if request.response_header.status == 200
        begin
          feed = Feedzirra::Feed.parse(request.response)
          @onfeed.call(feed) if @onfeed
          feed.entries.each {|entry| @onentry.call(entry)} if @onentry
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
