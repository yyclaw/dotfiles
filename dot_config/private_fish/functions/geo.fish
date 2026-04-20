function geo
    set -l ip $argv[1]
    if test -z "$ip"
        set ip (curl -s https://ifconfig.co/ip 2>/dev/null)
    end
    curl -s "http://ip-api.com/json/$ip" | jq .
end
