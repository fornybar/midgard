# Reset NRestart of service if previous run was long enough
# Example:
#   ./resetfailed.sh cool.service 60
#   Will check if previous run of cool.service was longer than 60 seconds,
#   if so we reset NRestart.
#
# Recommended use is to run this process in ExecStopPost. We also check if last
# active enter was after last inactive exit, in case previous service activation failed.
#
# From Systemd config manual:
# InactiveExitTimestamp: intacive/failed -> activation
# ActiveEnterTimestamp: activating -> active
# ActiveExitTimestamp: active -> deactivating
# so we need
#   activeExit - activeEnter > condition, check if we have been running long enough
# and
#   activeEnter > inactiveExit, check that we are checking current start attempt

service=$1
condition=$2

echo "expowait($service): Checking last runtime with condition $condition sec"

active_enter=$(systemctl show "$service" -p ActiveEnterTimestampMonotonic --value)
active_exit=$(systemctl show "$service" -p ActiveExitTimestampMonotonic --value)
inactive_exit=$(systemctl show "$service" -p InactiveExitTimestampMonotonic --value)

if [[ "$inactive_exit" -ge active_enter ]]; then
  echo "expowait($service): Last active was not this start attempt, not resetting NRestarts"
  exit 0
fi

runtime=$(( (active_exit - active_enter) / 1000000 ))
if [[ "$runtime" -lt "$condition" ]]; then
  echo "expowait($service): Last runtime too short, not resetting NRestarts (runtime: $runtime)"
  exit 0
fi


echo "expowait($service): Resetting NRestarts for $service (runtime: $runtime sec)"
systemctl reset-failed "$service"
