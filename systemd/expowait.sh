# Wait exponentially with systemd service restart counter
# Example:
#   ./expowait.sh cool.service 4 3600
#   Will wait 4**NRestarts sec until reaching a max wait of 3600 sec.
#
# Recommended use is to put this in ExecStartPre, set Restart=always and
# StartLimitIntervalSec=0. Then we will restart on all exit statuses forever.
# Service will be in deactivating state while waiting for a new restart.
# On more complicated use one should be mindful of the service restart config.

service=$1
expo=$2
max_wait_sec=$3

n_restart=$(systemctl show "$service" -p NRestarts --value)
echo "expowait($service): Starting with expo=$expo max_wait_sec=$max_wait_sec"
wait_sec=$((n_restart**expo))

if [[ $wait_sec -gt $max_wait_sec ]]; then
  wait_sec=$max_wait_sec
fi

echo "expowait($service): Waiting for $wait_sec (NRestarts=$n_restart)"
sleep "$wait_sec"
