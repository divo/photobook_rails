# README

## Development instructions
App uses Redis/resque for Jobs.

```
brew install redis
redis-server /opt/homebrew/etc/redis.conf
bundle exec sidekiq
rails s
```
