# Use official Node.js image
FROM node:14

# Create app directory
WORKDIR /usr/src/app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Bundle app source
COPY . .

# Expose port
EXPOSE 3000

# Run tests
#RUN npm test

# Start application
CMD [ "npm", "start" ]
