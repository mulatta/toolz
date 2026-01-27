{ self, ... }:
{
  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    let
      # Extract license info
      extractLicense =
        license:
        if builtins.isAttrs license then
          {
            spdxId = license.spdxId or null;
            shortName = license.shortName or null;
            fullName = license.fullName or null;
            free = license.free or null;
            redistributable = license.redistributable or null;
          }
        else if builtins.isList license then
          builtins.map extractLicense license
        else
          null;

      # Extract maintainer info
      extractMaintainer =
        m:
        if builtins.isAttrs m then
          {
            name = m.name or null;
            email = m.email or null;
            github = m.github or null;
          }
        else
          null;

      # Extract version from package
      # Priority: pkg.version > parse from pkg.name > "unknown"
      extractVersion =
        pkg:
        pkg.version or (
          if pkg ? name then
            let
              fullName = pkg.name;
              # Try to match version pattern at the end: -X.Y.Z or -X.Y or similar
              parts = builtins.match "(.+)-([0-9]+[.0-9a-zA-Z-]*)" fullName;
            in
            if parts != null then builtins.elemAt parts 1 else "unknown"
          else
            "unknown"
        );

      # Extract package metadata for the index
      extractPackageMeta =
        packages:
        lib.mapAttrs (
          name: pkg:
          if lib.isDerivation pkg && pkg ? meta then
            {
              inherit name;
              pname = pkg.pname or name;
              version = extractVersion pkg;
              meta = {
                description = pkg.meta.description or null;
                longDescription = pkg.meta.longDescription or null;
                homepage = pkg.meta.homepage or null;
                license = extractLicense (pkg.meta.license or null);
                maintainers = builtins.map extractMaintainer (pkg.meta.maintainers or [ ]);
                platforms = pkg.meta.platforms or [ ];
                broken = pkg.meta.broken or false;
                unfree = pkg.meta.unfree or false;
              };
            }
          else
            null
        ) packages;

      # Filter out null values and website package
      filterPackages = attrs: lib.filterAttrs (name: v: v != null && name != "website") attrs;

      # Generate packages.json content (excluding website package itself)
      packagesJson = pkgs.writeText "packages.json" (
        builtins.toJSON (filterPackages (extractPackageMeta self'.packages))
      );

      # Configured branches (should match config.js)
      branches = [
        "release-25.05"
        "release-25.11"
        "unstable"
      ];

      # Website static files
      websiteStatic = pkgs.runCommand "toolz-website-static" { } ''
        mkdir -p $out/css $out/js

        cp ${self}/website/index.html $out/
        cp ${self}/website/css/styles.css $out/css/
        cp ${self}/website/js/config.js $out/js/
        cp ${self}/website/js/search.js $out/js/
      '';

      # Complete website with package data
      # For local development, all branches point to the same packages.json
      websiteFull = pkgs.runCommand "toolz-website" { } ''
        cp -r ${websiteStatic} $out
        chmod -R u+w $out

        # Create data directory for each branch (same data for local dev)
        ${lib.concatMapStringsSep "\n" (branch: ''
          mkdir -p $out/data/${branch}
          cp ${packagesJson} $out/data/${branch}/packages.json
        '') branches}
      '';

      # Development server script
      serveScript = pkgs.writeShellScriptBin "toolz-website-serve" ''
        echo "Serving toolz website at http://localhost:8000"
        echo "Press Ctrl+C to stop"
        cd ${websiteFull}
        ${pkgs.python3}/bin/python3 -m http.server 8000
      '';
    in
    {
      packages.website = websiteFull;

      apps.website-serve = {
        type = "app";
        program = "${serveScript}/bin/toolz-website-serve";
      };
    };
}
