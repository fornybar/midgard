{ pkgs, terranix }:
let
  inherit (pkgs.lib) hasSuffix filterAttrs;
  inherit (pkgs.lib.filesystem) listFilesRecursive;
  inherit (builtins) filter attrNames readDir;
in {
  mkTerraformConfig = { dir, modules ? [ ], recursive ? true }:
  let
    _files = if recursive then
        listFilesRecursive dir
      else
        # Get only files in top level of dir
        map (f: dir + "${f}") (attrNames (filterAttrs (n: t: t == "regular") (readDir dir)));

    terranixFiles = filter (n: hasSuffix ".tf.nix" n) _files;
  in terranix.lib.terranixConfiguration {
    inherit pkgs;
    modules = terranixFiles ++ modules;
    strip_nulls = false;
  };
}
