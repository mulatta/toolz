{
  lib,
  buildPythonPackage,
  fetchPypi,
  cargo,
  rustPlatform,
  rustc,
  libiconv,
  stdenv,
  # Python dependencies
  click,
  deepmerge,
  markdown,
  pygments,
  pyyaml,
  tomli,
  hatchling,
}:
let
  # Local pymdown-extensions 10.17.1 (zensical specific requirement)
  # NOTE: Not exposed globally to avoid conflicts with nixpkgs 10.14.3
  pymdown-extensions-local = buildPythonPackage rec {
    pname = "pymdown-extensions";
    version = "10.17.1";
    pyproject = true;

    src = fetchPypi {
      pname = "pymdown_extensions";
      inherit version;
      hash = "sha256-YNBf5V5/taHkdA/FdfrK0g3G7jp0jo09NrpEFC51zgM=";
    };

    build-system = [ hatchling ];
    dependencies = [
      markdown
      pyyaml
      pygments
    ];
    pythonImportsCheck = [ "pymdownx" ];
  };
in
buildPythonPackage rec {
  pname = "zensical";
  version = "0.0.9";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-W0Hi3dLxlpTm+muwIahQlaCfe9Cvt+pKtpTnPc3D2JI=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-n5PL2FhWKf7+TDcuQG8/xwViVXGcILdu60MXMbr3KUE=";
  };

  nativeBuildInputs = [
    cargo
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    rustc
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv
  ];

  propagatedBuildInputs = [
    click
    deepmerge
    markdown
    pygments
    pymdown-extensions-local
    pyyaml
    tomli
  ];

  pythonImportsCheck = [ "zensical" ];

  meta = with lib; {
    description = "A modern static site generator built by the creators of Material for MkDocs";
    homepage = "https://zensical.org/";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.unix;
  };
}
