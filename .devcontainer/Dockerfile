FROM elixir:otp-28

# Install direnv
RUN curl -sfL https://direnv.net/install.sh | bash

RUN echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
RUN echo 'source ~/.bashrc' >> ~/.bash_profile

# Install dependencies and inotify-tools
RUN apt-get update && apt-get install -y curl git inotify-tools

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && apt-get install -y nodejs

# Set up project folder
ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Install Hex and Rebar3
RUN mix local.hex --force && mix local.rebar --force