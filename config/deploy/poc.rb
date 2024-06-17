# frozen_string_literal: true

server 'sul-rizz-poc.stanford.edu', user: 'rizz', roles: %w[web app]

Capistrano::OneTimeKey.generate_one_time_key!
