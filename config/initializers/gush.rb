rails_root = Rails.root || File.dirname(__FILE__) + '/../..'
redis_config = YAML.load_file(rails_root.to_s + '/config/redis.yml')
redis_config.merge! redis_config.fetch(Rails.env, {})
redis_config.symbolize_keys!

Gush.configure do |config|
  config.redis_url = "redis://#{redis_config[:host]}:#{redis_config[:port]}/0"
end
