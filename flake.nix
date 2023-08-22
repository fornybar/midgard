{
  outputs = { self, ... }:
  let
    inherit (builtins) mapAttrs readDir;
    midgardOverlay = overlay: (final: prev: { midgard = (prev.midgard or { }) // (overlay final prev); });
    mapMidgardOverlay = mapAttrs (_: overlay: midgardOverlay overlay);
  in {
      inherit midgardOverlay mapMidgardOverlay;

      overlays.libMidgard = midgardOverlay (final: prev: let
        inherit (prev.lib) mapAttrs' nameValuePair removeSuffix foldAttrs;
      in {
        lib = {
          importDir = dir: mapAttrs' (n: v: nameValuePair (removeSuffix ".nix" n) (import "${dir}/${n}")) (readDir dir);
          systemdExpoRestart = import ./systemd prev;

          # Merge list of attributes into a single attribute set
          merge = foldAttrs (x: y: x // y) { };
        };
      });
  };
}
