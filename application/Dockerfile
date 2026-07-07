# Uses outdated image to trigger Trivy scan findings
FROM node:14-alpine

WORKDIR /usr/src/app

COPY src/package*.json ./
RUN npm install

# Copy BOTH the backend (src) and frontend (public) directories
COPY src/ ./src/
COPY public/ ./public/

# REQUIREMENT: Specific file with your name
RUN echo "Kamalpreet Kaur - Wiz Technical Exercise" > /wizexercise.txt

EXPOSE 3000

CMD ["node", "src/server.js"]