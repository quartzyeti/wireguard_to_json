#!/bin/bash

# Create a new folder for the JSON files
output_folder="json_output"
mkdir -p "$output_folder"

# Get the list of .conf files
conf_files=(*.conf)

# Prompt the user for conversion preference
echo "Would you like to convert ALL configuration files or select specific ones?"
echo "Enter 'y' for ALL or 'n' for specific selection: "
read -r convert_all

if [[ $convert_all == "n" || $convert_all == "N" ]]; then
    # Display the list of configuration files with numbers
    echo "Please select the configuration files you want to convert (comma-separated):"
    for ((i=0; i<${#conf_files[@]}; i++)); do
        echo "$((i+1)). ${conf_files[i]}"
    done

    # Read the user's selection
    read -r selection

    # Convert the user's selection to an array
    IFS=',' read -ra selected_files <<< "$selection"

    # Create a new array with the selected files
    selected_conf_files=()
    for file_num in "${selected_files[@]}"; do
        index=$((file_num - 1))
        if [[ $index -ge 0 && $index -lt ${#conf_files[@]} ]]; then
            selected_conf_files+=("${conf_files[index]}")
        fi
    done
else
    # Use all configuration files if 'y' is selected
    selected_conf_files=("${conf_files[@]}")
fi

# Process the selected configuration files
for conf_file in "${selected_conf_files[@]}"; do
    if [ -f "$conf_file" ]; then
        # Extract values from the .conf file
        private_key=$(grep -oP '(?<=PrivateKey = ).*' "$conf_file")
        address=$(grep -oP '(?<=Address = )[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+' "$conf_file")
        mtu=$(grep -oP '(?<=MTU = ).*' "$conf_file")
        public_key=$(grep -oP '(?<=PublicKey = ).*' "$conf_file")
        allowed_ips=$(grep -oP '(?<=AllowedIPs = )[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+' "$conf_file")
        endpoint=$(grep -oP '(?<=Endpoint = ).*' "$conf_file")
        preshared_key=$(grep -oP '(?<=PresharedKey = ).*' "$conf_file")
        reserved=$(grep -oP '(?<=Reserved = ).*' "$conf_file")
        dns=$(grep -oP '(?<=DNS = ).*' "$conf_file")

        # Check if required values are present
        if [ -z "$private_key" ] || [ -z "$public_key" ] || [ -z "$address" ] || [ -z "$allowed_ips" ] || [ -z "$endpoint" ]; then
            echo "Error: Missing required values in $conf_file. Skipping conversion."
            continue
        fi

        # Join reserved integers with a space character
        reserved=$(echo $reserved | tr '\n' ' ')

        # Create the JSON object
        json_output=$(jq -n \
            --arg private_key "$private_key" \
            --arg address "$address" \
            --arg mtu "$mtu" \
            --arg public_key "$public_key" \
            --arg allowed_ips "$allowed_ips" \
            --arg endpoint "$endpoint" \
            --argjson reserved "[$reserved]" \
            --arg preshared_key "$preshared_key" \
            --arg dns "$dns" \
            '{
                "outbounds": [
                    {
                        "protocol": "wireguard",
                        "settings": {
                            "secretKey": $private_key,
                            "address": [$address],
                            "dns": ($dns | split(",") | map(ltrimstr(" ")) | if length > 0 then . else null end),
                            "peers": [
                                {
                                    "publicKey": $public_key,
                                    "preSharedKey": ($preshared_key | if . == "" then null else . end),
                                    "keepAlive": 25,
                                    "allowedIPs": [$allowed_ips],
                                    "endpoint": $endpoint
                                }
                            ],
                            "reserved": $reserved,
                            "mtu": ($mtu | tonumber? // null)
                        },
                        "tag": "wireguard"
                    }
                ]
            }')

        # Write the JSON output to a file with the same name as the .conf file inside the output folder
        json_file="${output_folder}/${conf_file%.conf}.json"
        echo "$json_output" > "$json_file"
        echo "Converted $conf_file to $json_file"
    fi
done