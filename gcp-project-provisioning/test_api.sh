#!/bin/bash
#
API_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
#
# Ensure the API key is present
if [ -z "$API_KEY" ]; then
    echo "Error: API_KEY is not set."
    exit 1
fi

# Define the API endpoint and model
MODEL="gemini-3.1-flash-lite-preview"
URL="https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent?key=${API_KEY}"

# Execute the curl command
curl $URL \
    -H 'Content-Type: application/json' \
    -X POST \
    -d '{
      "contents": [{
        "parts":[{"text": "Write a short tagline for a futuristic mobile app."}]
      }]
    }'
