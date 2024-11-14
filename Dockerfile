FROM ruby:3.1-bookworm as base
RUN apt-get update -qq && apt-get install -y build-essential apt-utils libpq-dev nodejs libvips-dev postgresql-client

WORKDIR /docker/app

RUN gem install bundler
COPY Gemfile* ./
RUN bundle install --jobs 20 --retry 5

COPY . /docker/app
COPY shared/. /shared/

RUN bundle exec rake assets:precompile

EXPOSE 3000

CMD [ "bundle", "exec", "puma", "config.ru"]
