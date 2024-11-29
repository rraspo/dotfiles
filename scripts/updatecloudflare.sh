#!/bin/bash

# Load .env file
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo "Error: .env file not found."
  exit 1
fi

# Check if required environment variables are set
if [[ -z "$API_BASE" || -z "$API_KEY" || -z "$EMAIL" || -z "$DOMAIN" ]]; then
  echo "Error: Missing required variables in .env file (API_BASE, API_KEY, EMAIL, DOMAIN)."
  exit 1
fi

get_public_ip() {
  curl -s -4 https://ifconfig.me
}

get_dns_record() {
  curl -s -X GET "$API_BASE/zones/$ZONE_ID/dns_records?name=$DNS_RECORD_NAME" \
    --header "X-Auth-Email: $EMAIL" \
    --header "X-Auth-Key: $API_KEY" \
    -H "Content-Type:application/json"
}

if [[ -n "$SUBDOMAINS" ]]; then
  echo "Subdomains are set: $SUBDOMAINS"
  IFS=' ' read -r -a SUBDOMAINS <<< "$SUBDOMAINS"
  for SUBDOMAIN in "${SUBDOMAINS[@]}"; do
    echo "Processing subdomain: $SUBDOMAIN"
    DNS_RECORD_ID=$(get_dns_record_id "$SUBDOMAIN")
    if [[ -z "$DNS_RECORD_ID" ]]; then
      echo "Error: Could not find DNS record for $SUBDOMAIN."
      continue
    fi
    update_dns_record "$SUBDOMAIN" "$DNS_RECORD_ID" "$PUBLIC_IP"
  done

fi

update_dns_record() {
  RECORD_ID=$2
  CURRENT_IP=$1
  echo "DNS Record: $(get_dns_record_id)"
  echo "$API_BASE/zones/$ZONE_ID/dns_records/$RECORD_ID"
  echo "Zone: $ZONE_ID"
  echo "Record: $RECORD_ID"
  echo "$(generate_post_data)"
  curl --request PATCH \
    --url "$API_BASE/zones/$ZONE_ID/dns_records/$RECORD_ID" \
    --header "X-Auth-Email: $EMAIL" \
    --header "X-Auth-Key: $API_KEY" \
    --header "Content-Type: application/json" \
    --data "$(generate_post_data)"
}

generate_post_data()
{
  cat <<EOF
{
    "comment": "Domain verification record",
    "name": "$DNS_RECORD_NAME",
    "proxied": true,
    "settings": {},
    "tags": [],
    "ttl": 3600,
    "content": "$CURRENT_IP",
    "type": "A"
}
EOF
}

# Main logic
PUBLIC_IP=$(get_public_ip)
echo $PUBLIC_IP
if [ -z "$PUBLIC_IP" ]; then
  echo "Error: Unable to fetch public IP."
  exit 1
fi

# echo "Updating DNS record $DNS_RECORD_NAME with IP $PUBLIC_IP..."
echo $RECORD_ID
echo $PUBLIC_IP
RESPONSE_ID=$(get_dns_record | jq -r ".result[0].id")
echo $RESPONSE_ID
get_dns_record | jq
update_dns_record "$PUBLIC_IP" "$RESPONSE_ID"
