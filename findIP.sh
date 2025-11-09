#!/bin/bash

start_ip="172.16.58.125"
end_ip="172.16.59.130"

ip_to_int() {
    local IFS=.
    read -r i1 i2 i3 i4 <<< "$1"
    echo $(( (i1 << 24) + (i2 << 16) + (i3 << 8) + i4 ))
}

int_to_ip() {
    local ip_int=$1
    echo "$(( (ip_int >> 24) & 255 )).$(( (ip_int >> 16) & 255 )).$(( (ip_int >> 8) & 255 )).$(( ip_int & 255 ))"
}

start=$(ip_to_int "$start_ip")
end=$(ip_to_int "$end_ip")

for (( ip=$start; ip<=$end; ip++ )); do
    current_ip=$(int_to_ip $ip)

    if ping -c 1 "$current_ip"; then
        echo "IP répondante trouvée : $current_ip"
        exit 0
    fi
done

echo "Aucune IP ne répond au ping dans la plage spécifiée."
exit 1
