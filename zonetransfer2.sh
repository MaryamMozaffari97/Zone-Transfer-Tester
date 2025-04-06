#!/bin/bash

# Check if domains.txt exists
if [ ! -f domain.txt ]; then
    echo "File domain.txt not found!"
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
done < domain.txt

# Prepare output JSON structure for all results
output="{\"zone_transfers\":["

# Prepare output JSON structure for successful transfers
successful_output="{\"successful_transfers\":["

# Iterate over each domain in domain.txt for zone transfer testing
while read -r domain; do
    if [[ ! -z "$domain" ]]; then
        # For each domain, iterate over its associated NS servers
        for ns_server in "${!ns_records[@]}"; do
            transfer=$(dig "$domain" @"$ns_server" AXFR 2>&1)
            echo -e "$transfer for domain=$domain and ns=$ns_server\n"
            
            # Clean up transfer data to remove control characters and escape any quotes
            cleaned_transfer=$(echo "$transfer" | tr -d '[:cntrl:]')
            
            if echo "$cleaned_transfer" | grep -qE 'failed|couldn'\''t'; then
                status="failed"
                transfer_data="$cleaned_transfer"
            else
                status="successful"
                transfer_data="$cleaned_transfer"

                # Append the successful transfer result to the successful output JSON
                successful_output+="{\"domain\":\"$domain\", \"ns_server\":\"$ns_server\", \"transfer_status\":\"$status\", \"transfer_data\":$(echo "$transfer_data" | jq -R .)},"
            fi
            
            # Append the result to the main JSON output, escaping any quotes in transfer data
            output+="{\"domain\":\"$domain\", \"ns_server\":\"$ns_server\", \"transfer_status\":\"$status\", \"transfer_data\":$(echo "$transfer_data" | jq -R .)},"
        done
    fi
done < domain.txt

# Remove the trailing comma and close the JSON arrays
output=${output%,}
output+="]}"
successful_output=${successful_output%,}
successful_output+="]}"

# Save output to a JSON file, ensuring proper formatting with jq
echo "$output" | jq . > zone_transfers2.json

# Save successful transfers to a separate JSON file
echo "$successful_output" | jq . > successful_zone_transfers.json

echo "Zone transfer results saved to zone_transfers2.json"
echo "Successful zone transfer results saved to successful_zone_transfers.json"