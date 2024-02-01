#!/bin/bash

# Function to check if a command is available
check_command() {
  command -v "$1" >/dev/null 2>&1 || { echo >&2 "$1 is not installed. Aborting."; exit 1; }
}

# Function to download and unzip the artifact
download_and_unzip() {
  url=$1
  filename=$(basename "$url")

  echo "Downloading artifact from $url..."
  curl -O "$url"

  echo "Unzipping $filename..."
  tar -xzvf "$filename"
}

# Install NodeJS and NPM using the latest setup version from nodesource
check_command "curl"
check_command "tar"
check_command "node"

echo "Installing NodeJS and NPM..."
curl -sL https://deb.nodesource.com/setup_latest | sudo -E bash -
sudo apt-get install -y nodejs

# Print installed NodeJS and NPM versions
echo "NodeJS version: $(node --version)"
echo "NPM version: $(npm --version)"

# Download and unzip the artifact
download_and_unzip "https://node-envvars-artifact.s3.eu-west-2.amazonaws.com/bootcamp-node-envvars-project-1.0.0.tgz"

# Set environment variables
export APP_ENV=dev
export DB_USER=myuser
export DB_PWD=mysecret

# Change into the package directory
cd package

# Run NodeJS application in the background
echo "Running npm install..."
npm install

echo "Running node server.js in the background..."
nohup node server.js &

# Wait for the application to start
sleep 5

# Check if the application has started successfully
if [ -n "$(pgrep -f 'node server.js')" ]; then
  # Get the process ID (PID) of the running NodeJS application
  pid=$(pgrep -o -f 'node server.js')

  # Get the port on which the application is listening
  port=$(netstat -tlnp 2>/dev/null | awk '/node/ {split($NF, a, "/"); print a[1]}')

  echo "NodeJS application has started successfully."
  echo "PID: $pid"
  echo "Listening on port: $port"
else
  echo "NodeJS application failed to start. Check logs for details."
fi

echo "You can check the logs in nohup.out."
