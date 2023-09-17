{
  description = "ExpidusOS Writer";

  nixConfig = rec {
    trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" ];
    substituters = [ "https://cache.nixos.org" "https://cache.garnix.io" ];
    trusted-substituters = substituters;
    fallback = true;
    http2 = false;
  };

  inputs.expidus-sdk = {
    url = github:ExpidusOS/sdk;
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.nixpkgs.url = github:ExpidusOS/nixpkgs;

  outputs = { self, expidus-sdk, nixpkgs }:
    with expidus-sdk.lib;
    flake-utils.eachSystem flake-utils.allSystems (system:
      let
        pkgs = expidus-sdk.legacyPackages.${system};
        deps = builtins.fromJSON (readFile ./deps.json);
        shortRev = self.shortRev or (substring 7 7 fakeHash);
        shortRevCodes = map strings.charToInt (stringToCharacters shortRev);
        buildCode = foldr (a: b: "${toString a}${toString b}") "" shortRevCodes;

        shortVersion = builtins.elemAt (splitString "+" (builtins.elemAt deps 0).version) 0;
        version = "${shortVersion}+${buildCode}";
      in {
        packages.default = pkgs.flutter.buildFlutterApplication {
          pname = "expidus-writer";
          version = "${shortVersion}+git-${shortRev}";

          src = cleanSource self;

          flutterBuildFlags = [
            "--dart-define=COMMIT_HASH=${shortRev}"
          ];

          nativeBuildInputs = with pkgs; [ wrapGAppsHook ];

          depsListFile = ./deps.json;
          vendorHash = "sha256-k0CtZyI8VQ9Rgk0Yw0pPaQIXcIpF/i/2WxVuw6CAHgQ=";

          postInstall = ''
            rm $out/bin/writer
            ln -s $out/app/writer $out/bin/expidus-writer

            mkdir -p $out/share/applications
            mv $out/app/data/com.expidusos.writer.desktop $out/share/applications

            mkdir -p $out/share/icons
            mv $out/app/data/com.expidusos.writer.png $out/share/icons

            mkdir -p $out/share/metainfo
            mv $out/app/data/com.expidusos.writer.metainfo.xml $out/share/metainfo

            substituteInPlace "$out/share/applications/com.expidusos.writer.desktop" \
              --replace "Exec=writer" "Exec=$out/bin/expidus-writer" \
              --replace "Icon=com.expidusos.writer" "Icon=$out/share/icons/com.expidusos.writer.png"
          '';

          meta = {
            description = "ExpidusOS Writer";
            homepage = "https://expidusos.com";
            license = licenses.gpl3;
            maintainers = with maintainers; [ RossComputerGuy ];
            platforms = [ "x86_64-linux" "aarch64-linux" ];
          };
        };

        devShells.default = pkgs.mkShell {
          inherit (self.packages.${system}.default) pname version name;

          GSETTINGS_SCHEMA_DIR = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas";

          packages = with pkgs; [ flutter ];
        };
      });
}
