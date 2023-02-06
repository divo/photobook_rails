# README

## Development instructions
App uses Redis/resque for Jobs.

```
brew install redis
redis-server /opt/homebrew/etc/redis.conf
COUNT=10 QUEUE=* rake resque:workers
rails s
```
