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
  DOMAIN=$1
  SUBDOMAIN=$2
  if [[ -z "$2" ]] then
    curl -s -X GET "$API_BASE/zones/$ZONE_ID/dns_records?name=$DOMAIN" \
      --header "X-Auth-Email: $EMAIL" \
      --header "X-Auth-Key: $API_KEY" \
      -H "Content-Type:application/json"
  else
    curl -s -X GET "$API_BASE/zones/$ZONE_ID/dns_records?name=$SUBDOMAIN.$DOMAIN" \
      --header "X-Auth-Email: $EMAIL" \
      --header "X-Auth-Key: $API_KEY" \
      -H "Content-Type:application/json"
  fi
}

update_dns_record() {
  CURRENT_IP=$1
  RECORD_ID=$2
  echo "DNS Record: $(get_dns_record)"
  echo "$API_BASE/zones/$ZONE_ID/dns_records/$RECORD_ID"
  echo "Zone: $ZONE_ID"
  echo "Record: $RECORD_ID"
  echo "$(generate_post_data "$SUBDOMAIN")"
  curl --request PATCH \
    --url "$API_BASE/zones/$ZONE_ID/dns_records/$RECORD_ID" \
    --header "X-Auth-Email: $EMAIL" \
    --header "X-Auth-Key: $API_KEY" \
    --header "Content-Type: application/json" \
    --data "$(generate_post_data "$SUBDOMAIN")"
}

generate_post_data() {
  local SUBDOMAIN=$1
  if [[ -z "$1" ]]; then
    cat <<EOF
{
    "comment": "Domain verification record",
    "name": "$DOMAIN",
    "proxied": true,
    "settings": {},
    "tags": [],
    "ttl": 3600,
    "content": "$CURRENT_IP",
    "type": "A"
}
EOF
  else
    cat <<EOF
{
    "comment": "Domain verification record",
    "name": "$SUBDOMAIN.$DOMAIN",
    "proxied": true,
    "settings": {},
    "tags": [],
    "ttl": 3600,
    "content": "$CURRENT_IP",
    "type": "A"
}
EOF
  fi
}

# Main logic
echo "Getting public IP..."
PUBLIC_IP=$(get_public_ip)
echo $PUBLIC_IP
if [ -z "$PUBLIC_IP" ]; then
  echo "Error: Unable to fetch public IP."
  exit 1
fi
echo "Getting DNS record..."
RESPONSE_ID=$(get_dns_record "$DOMAIN" | jq -r ".result[0].id")
echo $RESPONSE_ID
get_dns_record "$DOMAIN" | jq
printf "\n"
update_dns_record "$PUBLIC_IP" "$RESPONSE_ID"

if [[ -n "$SUBDOMAINS" ]]; then
  echo "Subdomains are set: $SUBDOMAINS"
  IFS=' ' read -r -a SUBDOMAINS <<<"$SUBDOMAINS"
  for SUBDOMAIN in "${SUBDOMAINS[@]}"; do
    printf "\nProcessing subdomain: $SUBDOMAIN"
    printf "\nGetting DNS record for $SUBDOMAIN...\n"
    RESPONSE_ID=$(get_dns_record "$DOMAIN" "$SUBDOMAIN" | jq -r ".result[0].id")
    echo $RESPONSE_ID
    get_dns_record "$DOMAIN" "$SUBDOMAIN" | jq
    printf "\n"
    update_dns_record "$PUBLIC_IP" "$RESPONSE_ID" "$SUBDOMAIN" 
  done
fi
