
# WireGuard Configuration to JSON Converter

This Bash script converts WireGuard configuration files (`.conf`) to JSON format suitable for use with the WireGuard protocol in a specific application or setup.

## Features

- Converts WireGuard configuration files to JSON format
- Supports converting all configuration files or selecting specific ones
- Extracts relevant values from the configuration files and creates a structured JSON object
- Handles missing required values and skips conversion for incomplete configuration files
- Outputs the converted JSON files to a separate folder (`json_output`)

## Prerequisites

- Bash shell environment
- `jq` command-line JSON processor installed

## Usage

1. Place the script file in the same directory as your WireGuard configuration files (`.conf`).

2. Make the script file executable by running the following command:
   ```
   chmod +x script_name.sh
   ```

3. Run the script using the following command:
   ```
   ./script_name.sh
   ```

4. When prompted, choose whether you want to convert all configuration files or select specific ones:
   - Enter 'y' to convert all configuration files.
   - Enter 'n' to select specific configuration files.

5. If you chose to select specific configuration files, enter the comma-separated list of file numbers corresponding to the configuration files you want to convert.

6. The script will process the selected configuration files and convert them to JSON format.

7. The converted JSON files will be saved in the `json_output` folder with the same name as the original configuration files, but with a `.json` extension.

## JSON Output Format

The converted JSON files will have the following structure:

```json
{
  "outbounds": [
    {
      "protocol": "wireguard",
      "settings": {
        "secretKey": "<private_key>",
        "address": ["<address>"],
        "peers": [
          {
            "publicKey": "<public_key>",
            "preSharedKey": "<preshared_key>",
            "keepAlive": 25,
            "allowedIPs": ["<allowed_ips>"],
            "endpoint": "<endpoint>"
          }
        ],
        "reserved": [<reserved_integers>],
        "mtu": <mtu>
      },
      "tag": "wireguard"
    }
  ]
}
```

The values enclosed in angle brackets (`<>`) will be replaced with the corresponding values extracted from the configuration files.

## Error Handling

If a configuration file is missing any required values (`PrivateKey`, `PublicKey`, `Address`, `AllowedIPs`, or `Endpoint`), the script will skip the conversion for that file and display an error message.

## License

This script is released under the [MIT License](LICENSE).

Feel free to modify and use this script according to your needs.
