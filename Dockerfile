FROM ruby:3.2.0-slim
RUN mkdir -p /app
WORKDIR /app
COPY Gemfile* /app/
RUN bundle install 
ADD . .
CMD ["bin/rackup"]
