# zone-transfer-tester
A Bash script to test zone transfers for a list of domains.

## Usage
1. Place a list of domains in a file named `domains.txt`.
2. Run the script using `bash zone_transfer_tester.sh`.
3. Results will be saved in `zone_transfers2.json`.

## Security Considerations
Zone transfers can expose sensitive DNS information. Use this script responsibly.

## Testing Domains
For testing purposes, you can use domains like `zonetransfer.me`.

## Zone Transfer Definition
Zone transfers are a mechanism used by DNS servers to replicate DNS records between primary and secondary name servers. This process involves transferring a copy of the zone file, which contains all DNS records for a domain, from one server to another. While zone transfers are essential for maintaining DNS redundancy and availability, they can also pose security risks if not properly restricted. If a domain allows zone transfers from any IP address, it can expose sensitive information about internal network structures and hostnames. Therefore, zone transfers should be restricted to authorized IP addresses to prevent unauthorized access.
