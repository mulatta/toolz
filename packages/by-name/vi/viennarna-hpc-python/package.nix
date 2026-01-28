{
  lib,
  buildPythonPackage,
  viennarna-hpc,
  swig,
  python,
}:
buildPythonPackage {
  pname = "viennarna-python";
  inherit (viennarna-hpc) version src;

  format = "other";

  nativeBuildInputs = [
    swig
  ];

  buildInputs = [
    viennarna-hpc
  ];

  buildPhase = ''
    cd interfaces/Python
    ${python.interpreter} setup.py build
  '';

  installPhase = ''
    cd interfaces/Python
    ${python.interpreter} setup.py install --prefix=$out
  '';

  pythonImportsCheck = [ "RNA" ];

  meta = {
    description = "Python bindings for ViennaRNA HPC";
    homepage = "https://www.tbi.univie.ac.at/RNA/";
    license = lib.licenses.free;
    platforms = lib.platforms.unix;
  };
}
