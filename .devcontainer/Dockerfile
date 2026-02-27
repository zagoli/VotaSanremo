# Use an official Erlang image as the base
FROM erlang:28

# Environment variables for ASDF
ENV ASDF_VERSION="v0.15.0" LANG=C.UTF-8

# Install system dependencies in a single layer
RUN apt-get update && apt-get install -y \
    curl \
    git \
    inotify-tools \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install direnv
RUN curl -sfL https://direnv.net/install.sh | bash
RUN echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
RUN echo 'source ~/.bashrc' >> ~/.bash_profile

# Install Node.js 22 LTS
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install ASDF and Elixir (latest version compatible with current OTP)
RUN git clone https://github.com/asdf-vm/asdf.git /root/.asdf --branch $ASDF_VERSION
ENV PATH="/root/.asdf/bin:/root/.asdf/shims:$PATH"
RUN asdf plugin add elixir \
    && asdf install elixir latest \
    && asdf global elixir latest

# Set up project folder
ENV APP_HOME=/app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Install Hex and Rebar3
RUN mix local.hex --force && mix local.rebar --force
