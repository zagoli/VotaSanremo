# Use an official Erlang image as the base
FROM erlang:27.1.2

# Environment variables for ASDF
ENV ASDF_VERSION="v0.10.2" LANG=C.UTF-8

# Install direnv
RUN curl -sfL https://direnv.net/install.sh | bash

RUN echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
RUN echo 'source ~/.bashrc' >> ~/.bash_profile

# Install dependencies and inotify-tools
RUN apt-get update && apt-get install -y curl git inotify-tools

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && apt-get install -y nodejs

# Install ASDF and Elixir
RUN git clone https://github.com/asdf-vm/asdf.git /root/.asdf --branch $ASDF_VERSION
ENV PATH="/root/.asdf/bin:/root/.asdf/shims:$PATH"
RUN asdf plugin-add elixir && asdf install elixir 1.17.0 && asdf global elixir 1.17.0

# Set up project folder
ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Install Hex and Rebar3
RUN mix local.hex --force && mix local.rebar --force