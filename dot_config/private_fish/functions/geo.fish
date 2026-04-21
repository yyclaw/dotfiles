function geo
    set -l ip $argv[1]
    curl -s "http://ip-api.com/json/$ip" | jq .
end
