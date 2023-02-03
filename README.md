# README

## Development instructions
App uses Redis/resque for Jobs.

```
brew install redis
redis-server /opt/homebrew/etc/redis.conf
QUEUE=* rake resque:work
rails s
```
