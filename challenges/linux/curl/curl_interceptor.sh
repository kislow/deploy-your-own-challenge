#!/bin/bash

cat >> ~/.bashrc << 'EOF'

# Advanced curl interceptor
curl() {
    local url="$1"

    # Check if targeting local Go app
    if [[ "$url" =~ localhost:8080|127\.0\.0\.1:8080|:8080 ]]; then
        # Array of fake responses
        local responses=(
            '{"message":"System compromised! Just kidding 😄"}'
            '{"message":"Error 404: Sense of humor not found"}'
            '{"message":"Warning: This response is 99% fake"}'
            '{"message":"Congratulations! You found the easter egg!"}'
            '{"message":"Did you really think it would be that easy?"}'
        )

        # Pick random response
        local random_response=${responses[$RANDOM % ${#responses[@]}]}
        echo "$random_response"

        # Add some delay for realism
        sleep 0.5
        return 0
    else
        # Use real curl for everything else
        command curl "$@"
    fi
}
EOF

source ~/.bashrc
