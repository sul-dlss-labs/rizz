FROM sul-dlss/kakadu-vips:latest

WORKDIR /tmp
COPY Gemfile .

# SHELL ["/bin/bash", "-c"]
# USER ruby
# RUN echo whoami
# RUN ruby -v
USER root
RUN bundle install

# docker run -v $(pwd):/rizz -p 3000:3000 -it $(docker build -q .)
USER ruby
WORKDIR /rizz
CMD ["bundle", "exec", "falcon", "serve", "--bind", "https://0.0.0.0:3000"]
