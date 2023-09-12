{ pkgs, inputs }:

let
  disabledPlugins = [
    # That one is not technically a plugin, but by putting it in this list, we
    # get it removed from the top level list of requirement and it is not pull
    # in the nix shell.
    "shake-bench"
  ];

  hpkgsOverride = hself: hsuper:
    with pkgs.haskell.lib;
    {
      hlsDisabledPlugins = disabledPlugins;
    } // (builtins.mapAttrs (_: drv: disableLibraryProfiling drv) {
      apply-refact = hsuper.apply-refact_0_13_0_0;

      fourmolu = dontCheck (hself.callCabal2nix "fourmolu" inputs.fourmolu-013 {});
      Cabal-syntax = hsuper.Cabal-syntax_3_10_1_0;
      Cabal = hsuper.Cabal_3_10_1_0;
      ghc-lib-parser-ex = hsuper.ghc-lib-parser-ex_9_6_0_1;
      ormolu = hsuper.ormolu_0_7_1_0;
      ghc-lib-parser = hsuper.ghc-lib-parser_9_6_2_20230523;
      stylish-haskell = appendConfigureFlag  hsuper.stylish-haskell_0_14_5_0 "-fghc-lib";

      lsp = hself.callCabal2nix "lsp" inputs.lsp {};
      lsp-types = hself.callCabal2nix "lsp-types" inputs.lsp-types {};
      lsp-test = dontCheck (hself.callCabal2nix "lsp-test" inputs.lsp-test {});

      # Re-generate HLS drv excluding some plugins
      haskell-language-server =
        hself.callCabal2nixWithOptions "haskell-language-server" ./.
        # Pedantic cannot be used due to -Werror=unused-top-binds
        # Check must be disabled due to some missing required files
        (pkgs.lib.concatStringsSep " " [ "--no-check" "-f-pedantic" "-f-hlint" ]) { };
    });
in {
  inherit disabledPlugins;
  tweakHpkgs = hpkgs: hpkgs.extend hpkgsOverride;
}
