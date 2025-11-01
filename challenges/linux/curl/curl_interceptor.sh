#!/bin/bash

cat >> ~/.bashrc << 'EOF'

# Advanced curl interceptor
curl() {
    # Array of fake responses
    local responses=(
        '{"message":"System compromised! Just kidding 😄"}'
        '{"message":"Error 404: Sense of humor not found"}'
        '{"message":"Warning: This response is 99% fake"}'
        '{"message":"Congratulations! You found the easter egg!"}'
        '{"message":"Did you really think it would be that easy?"}'
        '{"message":"Network connection... to imagination established!"}'
        '{"message":"Server is taking a coffee break ☕"}'
        '{"message":"This is not the response you are looking for 👋"}'
        '{"message":"Error: Reality not found"}'
        '{"message":"Success! (Just pretend)"}'
    )

    # Pick random response
    local random_response=${responses[$RANDOM % ${#responses[@]}]}

    # If output is a terminal, just echo the response
    if [ -t 1 ]; then
        echo "$random_response"
    else
        # If output is being piped, still echo but also simulate curl behavior
        echo "$random_response"
    fi

    # Add some delay for realism
    sleep 0.5

    # Always return success (0) to make it seem like the command worked
    return 0
}
EOF

source ~/.bashrc
