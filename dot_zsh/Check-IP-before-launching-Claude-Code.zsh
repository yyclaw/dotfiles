#!/bin/zsh

cc() {
  # Configuration
  local proxy_url="http://127.0.0.1:8118"
  local target_country="US"
  local ip_service="https://ifconfig.co/ip"
  local geo_service="http://ip-api.com/json"
  local timeout=3

  # Set proxy
  __set_proxy "$proxy_url"

  # Get current IP
  local ip
  ip=$(curl -s --connect-timeout "$timeout" --max-time $((timeout * 2)) "$ip_service" 2>/dev/null)

  # Validate IP
  if [[ -z "$ip" ]]; then
    print "❌ Failed to get IP address. Connect to the VPN first."
    return 1
  fi

  if ! __is_ipv4 "$ip" && ! __is_ipv6 "$ip"; then
    print "❌ Invalid IP format: $ip"
    return 1
  fi

  print "📍 IP: $ip"

  # Get geolocation data
  local geo_data
  geo_data=$(curl -s --connect-timeout "$timeout" --max-time $((timeout * 2)) "$geo_service/$ip" 2>/dev/null)

  if [[ -z "$geo_data" ]]; then
    print "❌ Geolocation service unavailable."
    return 1
  fi

  # Parse country code
  local country_code
  if ! country_code=$(print "$geo_data" | jq -r '.countryCode // empty' 2>/dev/null); then
    print "❌ Failed to parse geolocation data."
    return 1
  fi

  if [[ -z "$country_code" ]]; then
    print "❌ Country code not found in response."
    return 1
  fi

  # Check country
  if [[ "$country_code" != "$target_country" ]]; then
    print "❌ IP location: $country_code (expected: $target_country)"
    return 1
  fi

  print "✅ IP location verified: $target_country"
  print
  claude "$@" # Pass-through parameters
}

__set_proxy() {
  local vpn_proxy_url="${1:-http://127.0.0.1:8118}"
  export https_proxy="$vpn_proxy_url"
  export http_proxy="$vpn_proxy_url"
}

__is_ipv4() {
  local ip="$1"
  local regex='^([0-9]{1,3}\.){3}[0-9]{1,3}$'

  [[ "$ip" =~ $regex ]] || return 1

  # Validate each octet is <= 255
  local IFS='.'
  local octets=($ip)
  for octet in "${octets[@]}"; do
    ((octet >= 0 && octet <= 255)) || return 1
  done

  return 0
}

__is_ipv6() {
  local ip="$1"
  # Simplified IPv6 regex - covers most common formats
  local regex='^(([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]+|::(ffff(:0{1,4})?:)?((25[0-5]|(2[0-4]|1?[0-9])?[0-9])\.){3}(25[0-5]|(2[0-4]|1?[0-9])?[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1?[0-9])?[0-9])\.){3}(25[0-5]|(2[0-4]|1?[0-9])?[0-9]))$'

  [[ "$ip" =~ $regex ]]
}
