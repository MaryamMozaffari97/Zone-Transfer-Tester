# Zone Transfer Testing Tool (`zonetransfer.sh`)

## Overview

This Bash script, `zonetransfer.sh`, is a command-line tool to test DNS zone transfers for a list of domains. It reads domains from a specified file, extracts the NS records for each domain, and attempts a zone transfer (AXFR) from each NS server. The results, including transfer status and the zone data, are saved in JSON format.

## Features

-   **Domain List Input**: Reads a list of domains from a text file.
-   **NS Record Extraction**: Automatically extracts NS records using `dig`.
-   **Zone Transfer Testing**: Performs zone transfer attempts using `dig` against each NS server.
-   **JSON Output**: Saves the results in a structured JSON format using `jq` for easy parsing and analysis.
-   **Command-Line Options**:
    -   `-h`: Displays a help message with usage instructions.
    -   `-d <domain_file>`: Specifies the path to the domain list file (default: `domain.txt`).
    -   `-o <output_file>`: Specifies the name of the output JSON file (default: `output.json`).

## Requirements

-   **Bash**: The script is written in Bash and requires a Bash-compatible environment.
-   **dig**: The `dig` command-line tool (part of the `bind9-dnsutils` package on Debian/Ubuntu) is used for DNS queries and zone transfers.
-   **jq**: The `jq` command-line JSON processor is used to format the output JSON.

## Installation

1.  **Install `dig`**:

    ```
    sudo apt update
    sudo apt install bind9-dnsutils
    ```

2.  **Install `jq`**:

    ```
    sudo apt update
    sudo apt install jq
    ```

3.  **Download the Script**:

    Save the script as `zonetransfer.sh` to your desired directory.

4.  **Make the Script Executable**:

    ```
    chmod +x zonetransfer.sh
    ```

## Usage
./zonetransfer.sh [options]

### Options

-   `-h`: Displays the help message.
-   `-d <domain_file>`: Specifies the domain list file (default: `domain.txt`).
-   `-o <output_file>`: Specifies the output JSON file (default: `output.json`).

### Example

./zonetransfer.sh -d my_domains.txt -o results.json

This command will read domains from `my_domains.txt`, perform zone transfers, and save the results to `results.json`.

### Domain List File Format

The domain list file (`domain.txt` by default) should contain one domain per line:

zonetransfer.me
example.com
anotherdomain.org
