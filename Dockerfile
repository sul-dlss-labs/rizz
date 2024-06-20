FROM sul-dlss/kakadu-vips:latest

USER ruby
WORKDIR /tmp
COPY Gemfile .

RUN bundle install

WORKDIR /rizz
CMD bundle install && bundle exec puma -C config/puma.rb config.ru
