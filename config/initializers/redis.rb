rails_root = Rails.root || File.dirname(__FILE__) + '/../..'
redis_config = YAML.load_file(rails_root.to_s + '/config/redis.yml')
redis_config.merge! redis_config.fetch(Rails.env, {})
redis_config.symbolize_keys!

RedisClient.config(host: redis_config[:host], port: redis_config[:port], db: 0)
