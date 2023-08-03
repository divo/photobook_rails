FROM ruby:3.1-bookworm as base
RUN apt-get update -qq && apt-get install -y build-essential apt-utils libpq-dev nodejs libvips-dev postgresql-client

WORKDIR /docker/app

RUN gem install bundler
COPY Gemfile* ./
RUN bundle install

COPY . /docker/app
COPY sockets/. /shared/sockets/
COPY log/. /shared/log/

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD [ "bundle", "exec", "puma", "config.ru"]
