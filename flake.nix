{
  nixConfig.flake-registry = "https://raw.githubusercontent.com/fornybar/registry/main/registry.json";

  outputs = { self, nixpkgs, ... }@inputs:
  let
    inherit (builtins) mapAttrs readDir;
    inherit (nixpkgs.lib) mapAttrs' nameValuePair removeSuffix;
  in {

    lib = rec {
      midgardOverlay = overlay: (final: prev: { midgard = (prev.midgard or { }) // (overlay final prev); });
      mapMidgardOverlay = mapAttrs (_: overlay: midgardOverlay overlay);
      importDir = dir: mapAttrs' (n: v: nameValuePair (removeSuffix ".nix" n) (import "${dir}/${n}")) (readDir dir);
      systemdExpoRestart = import ./systemd;
    };
  };
}
