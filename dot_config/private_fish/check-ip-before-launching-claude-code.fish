function __set_proxy
    set -l vpn_proxy_url $argv[1]
    test -z "$vpn_proxy_url"; and set vpn_proxy_url "http://127.0.0.1:8118"
    set -gx https_proxy $vpn_proxy_url
    set -gx http_proxy $vpn_proxy_url
end

function __is_ipv4
    string match -rq '^([0-9]{1,3}\.){3}[0-9]{1,3}$' -- $argv[1]; or return 1
    for octet in (string split '.' -- $argv[1])
        test $octet -ge 0 -a $octet -le 255; or return 1
    end
end

function __is_ipv6
    string match -rq '^(([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:))$' -- $argv[1]
end

function cc
    set -l proxy_url "http://127.0.0.1:8118"
    set -l target_country "US"
    set -l ip_service "https://ifconfig.co/ip"
    set -l geo_service "http://ip-api.com/json"
    set -l timeout 3

    __set_proxy $proxy_url

    set -l ip (curl -s --connect-timeout $timeout --max-time (math "$timeout * 2") $ip_service 2>/dev/null)

    if test -z "$ip"
        echo "❌ Failed to get IP address. Connect to the VPN first."
        return 1
    end

    if not __is_ipv4 "$ip"; and not __is_ipv6 "$ip"
        echo "❌ Invalid IP format: $ip"
        return 1
    end

    echo "📍 IP: $ip"

    set -l geo_data (curl -s --connect-timeout $timeout --max-time (math "$timeout * 2") "$geo_service/$ip" 2>/dev/null)

    if test -z "$geo_data"
        echo "❌ Geolocation service unavailable."
        return 1
    end

    set -l country_code (echo $geo_data | jq -r '.countryCode // empty' 2>/dev/null)

    if test -z "$country_code"
        echo "❌ Country code not found in response."
        return 1
    end

    if test "$country_code" != "$target_country"
        echo "❌ IP location: $country_code (expected: $target_country)"
        return 1
    end

    echo "✅ IP location verified: $target_country"
    echo
    claude $argv
end
