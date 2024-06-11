FROM sul-dlss/kakadu-vips:latest


COPY images/ /images/


USER ruby
WORKDIR /tmp
COPY Gemfile .

RUN bundle install

WORKDIR /rizz
CMD bundle install && bundle exec falcon serve --bind https://0.0.0.0:3000
