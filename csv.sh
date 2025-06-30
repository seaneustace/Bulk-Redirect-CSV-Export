#!/bin/bash

# Function to display progress bar
progress_bar() {
  local progress=$1
  local total=$2
  local percent=$(( progress * 100 / total ))
  local bar=""

  for ((i=0; i<percent/2; i++)); do
    bar+="#"
  done
  printf "\rProgress: [%-50s] %d%%" "$bar" "$percent"
}

#Output Version Number
echo ""
echo "Sean's Bulk Redirect CSV Exporter v2.0 (Updated 6/27/2024):"
echo ""

# Get user input
read -p 'Enter your Cloudflare account ID: ' account_id
read -p 'Enter your Cloudflare API Token: ' api_key
echo

# List all lists
lists_response=$(curl -s --request GET \
  --url https://api.cloudflare.com/client/v4/accounts/$account_id/rules/lists \
  --header 'Content-Type: application/json' \
  --header "Authorization: Bearer $api_key")

# Parse and display list names and IDs
echo "Available Lists:"
echo "$lists_response" | jq -r '.result[] | "Name: \(.name)\nDescription: \(.description // "n/a")\nID: \(.id)\n"'

# Get user input for the list ID to edit
read -p 'Enter the List ID to export: ' user_list

# Get list details
list_details=$(curl -s --request GET \
  --url https://api.cloudflare.com/client/v4/accounts/$account_id/rules/lists/$user_list \
  --header 'Content-Type: application/json' \
  --header "Authorization: Bearer $api_key")

# Extract number of items
num_items=$(echo "$list_details" | jq -r '.result.num_items')

# Calculate total iterations and progress update frequency
total_iterations=$(( (num_items + 24) / 25 ))
progress_update_freq=$(( total_iterations / 100 + 1 ))

# Initialize CSV output
csv_results=""

cursor=""
iterations=0

# Iterate through list items
while true; do
  response=$(curl -s --request GET \
    --url "https://api.cloudflare.com/client/v4/accounts/$account_id/rules/lists/$user_list/items?cursor=$cursor" \
    --header 'Content-Type: application/json' \
    --header "Authorization: Bearer $api_key")

  while read -r item; do
    source_url=$(echo "$item" | jq -r '.redirect.source_url // "false"')
    target_url=$(echo "$item" | jq -r '.redirect.target_url // "false"')
    status_code=$(echo "$item" | jq -r '.redirect.status_code // "false"')
    preserve_query_string=$(echo "$item" | jq -r '.redirect.preserve_query_string // "false"')
    include_subdomains=$(echo "$item" | jq -r '.redirect.include_subdomains // "false"')
    subpath_matching=$(echo "$item" | jq -r '.redirect.subpath_matching // "false"')
    preserve_path_suffix=$(echo "$item" | jq -r '.redirect.preserve_path_suffix // "false"')

    csv_results+=$'\n'"$source_url,$target_url,$status_code,$preserve_query_string,$include_subdomains,$subpath_matching,$preserve_path_suffix"
  done < <(echo "$response" | jq -c '.result[]')

  cursor=$(echo "$response" | jq -r '.result_info.cursors.after // empty')
  iterations=$(( iterations + 1 ))

  if (( iterations % progress_update_freq == 0 )); then
    progress_bar $iterations $total_iterations
  fi

  if [ -z "$cursor" ]; then
    break
  fi
done

# Ensure progress bar reaches 100%
progress_bar $total_iterations $total_iterations
echo

# Save the results to a CSV file, removing the first newline character
echo -e "$csv_results" | sed '1d' > results.csv
echo "Results saved to results.csv"
