pkgs:
{
  service,
  expo ? 3,
  maxWaitSec ? 3600,
  resetSec ? 600,
  maxRetries ? null
}:
let
  inherit (builtins) readFile toString isNull;
  expowait = pkgs.writeShellApplication {
    name = "expowait"; text = readFile ./expowait.sh;
  };
  resetfailed = pkgs.writeShellApplication {
    name = "resetfailed"; text = readFile ./resetfailed.sh;
  };
  parseInt = x: assert builtins.isInt x; (toString x);
  # assertInt = x: assert builtins.isInt x; x;

in
{
  serviceConfig = {
    ExecStartPre = "${expowait}/bin/expowait ${service} ${parseInt expo} ${parseInt maxWaitSec}";
    ExecStopPost = "${resetfailed}/bin/resetfailed ${service} ${parseInt resetSec}";
    Restart = "always";
    TimeoutStartSec = (maxWaitSec + 10);
  };
  unitConfig = if (isNull maxRetries)
    then { StartLimitIntervalSec = 0;}
    else {
      StartLimitIntervalSec = maxWaitSec*(maxRetries+1);
      StartLimitBurst = maxRetries;
    };
}


