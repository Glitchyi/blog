# Use golang:1.23 as the base image
FROM golang:1.23

# Install Node.js and npm
RUN apt-get update && apt-get install -y nodejs npm

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json to the container
COPY package.json package-lock.json ./

# Run npm install to install Node.js dependencies
RUN npm install

# Copy the rest of the application code to the container
COPY . .

# Build the Go application
RUN go build -o blog

# Run the Go application
CMD ["./blog"]
