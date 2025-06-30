# Bulk-Redirect-CSV-Export
Searches Cloudflare's Bulk Redirect List for each paginated result and exports them back out to CSV.

# The Problem

For users who manage their Bulk Redirects via a CSV. Cloudflare only allows the ability to import via CSV and not export. This means you must managed your CSV locally rather than rely on Cloudflare to export your original CSV file. We are able to use the results from listing items inside the list ID and export them back out to a CSV.

## Note: Cloudflare API Token
The Cloudflare Api token need the **Account Filter List Read** permission for this script to function.

# Output

```
root@DESKTOP-HQOGOIQ:~/Bulk-Redirect-CSV-Export# chmod +x csv.sh
root@DESKTOP-HQOGOIQ:~/Bulk-Redirect-CSV-Export# ./csv.sh

Sean's Bulk Redirect CSV Exporter v2.0 (Updated 6/27/2024):

Enter your Cloudflare Account ID: e60f3efad5b2ch781sbs778122
Enter your Cloudflare API token: 11111cccc777bchg77761a

Available Lists:
Name: List 1
Description: this is my description for list 1
ID: eac77755jjdjdndndhhhs775757

Name: My favorite list 2
Description: A list of favorites
ID: 777ghhfnsjjjjs774kksnns

Name: Misc List 3
Description: Misc extra items
ID: d777ghhbcbba771bajjjf

Enter the List ID to export: eac77755jjdjdndndhhhs775757
Progress: [##################################################] 100%
Results saved to results.csv
```
