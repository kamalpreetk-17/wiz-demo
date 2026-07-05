# Uses outdated image to trigger Trivy scan findings
FROM node:14-alpine

WORKDIR /usr/src/app

# Copy package files from the src directory
COPY src/package*.json ./
RUN npm install

# Copy application source code
COPY src/ .

# REQUIREMENT: Specific file with your name
RUN echo "Kamalpreet Kaur - Wiz Technical Exercise" > /wizexercise.txt

EXPOSE 3000

CMD ["node", "server.js"]