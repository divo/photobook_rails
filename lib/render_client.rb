class RenderClient
  include HTTParty
    base_uri ENV['RENDER_APP_URL'] + ":" + ENV['RENDER_APP_PORT']

    def initialize()
      @options = { }
    end

    def ping
      # TODO: Error handling
      self.class.get("/ping", @options)
    end
end
