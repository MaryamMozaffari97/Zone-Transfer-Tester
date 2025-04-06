#!/bin/bash

# Set default values
DOMAIN_FILE="domain.txt"
OUTPUT_FILE="output.json"

# Function to display help message
show_help() {
  echo "Usage: $0 [-h] [-d domain_file] [-o output_file]"
  echo "  -h: Show help message"
  echo "  -d domain_file: Specify the domain file (default: domain.txt)"
  echo "  -o output_file: Specify the output file (default: output.json)"
  exit 0
}

# Parse command-line arguments
while getopts "hd:o:" opt; do
  case "$opt" in
    h)
      show_help
      ;;
    d)
      DOMAIN_FILE="$OPTARG"
      ;;
    o)
      OUTPUT_FILE="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      show_help
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      show_help
      exit 1
      ;;
  esac
done

# Check if the domain file exists
if [ ! -f "$DOMAIN_FILE" ]; then
  echo "File $DOMAIN_FILE not found!"
  exit 1
fi

# Initialize an associative array to hold NS records
declare -A ns_records

# Read each domain from the file and extract NS servers
while read -r domain; do
  if [[ ! -z "$domain" ]]; then
    # Extract NS records using dig and store them in the array
    ns=$(dig "$domain" NS +short)
    echo -e "$ns for domain= $domain\n"
    for ns_server in $ns; do
      ns_records["$ns_server"]+="$domain "
    done
  fi
done < "$DOMAIN_FILE"

# Prepare output JSON structure
output='{"zone_transfers": ['

# Iterate over each domain in domain.txt for zone transfer testing
while read -r domain; do
  if [[ ! -z "$domain" ]]; then
    # For each domain, iterate over its associated NS servers
    for ns_server in "${!ns_records[@]}"; do
      transfer=$(dig "$domain" @"$ns_server" AXFR 2>&1)
      echo -e "$transfer for domain=$domain and ns=$ns_server\n"
      
      # Clean up transfer data to remove control characters and escape any quotes
      cleaned_transfer=$(echo "$transfer" | tr -d '[:cntrl:]' | jq -R @json)
      
      if echo "$cleaned_transfer" | grep -qE 'failed|couldn'\''t'; then
        status="failed"
      else
        status="successful"
      fi
      
      # Append the result to the main JSON output
      output+="{\"domain\": \"$domain\", \"ns_server\": \"$ns_server\", \"transfer_status\": \"$status\", \"transfer_data\": $cleaned_transfer},"
    done
  fi
done < "$DOMAIN_FILE"

# Remove the trailing comma and close the JSON array
output=${output%,}
output+=' ]}'

# Save output to a JSON file, ensuring proper formatting with jq
echo "$output" | jq . > "$OUTPUT_FILE"

echo "Zone transfer results saved to $OUTPUT_FILE"