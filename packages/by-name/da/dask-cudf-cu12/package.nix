{
  lib,
  buildPythonPackage,
  fetchPypi,
  pythonOlder,
  cudf-cu12,
  cupy,
  fsspec,
  numpy,
  nvidia-ml-py,
  pandas,
  rapids-dask-dependency,
}:
buildPythonPackage rec {
  pname = "dask-cudf-cu12";
  version = "25.10.0";
  format = "wheel";

  disabled = pythonOlder "3.10";

  src = fetchPypi {
    pname = "dask_cudf_cu12";
    inherit version;
    format = "wheel";
    dist = "py3";
    python = "py3";
    hash = "sha256-cB/oqMFuE2+JBZikFi8QZAcda6imVlRpSnzEk5ezRhA=";
  };

  dependencies = [
    cudf-cu12
    cupy # cupy-cuda12x
    fsspec
    numpy
    nvidia-ml-py
    pandas
    rapids-dask-dependency
  ];

  # Skip tests - requires CUDA runtime and Dask cluster
  doCheck = false;

  # pythonImportsCheck = ["dask_cudf"];  # Skip - requires CUDA runtime

  meta = {
    description = "Dask integration for cuDF GPU DataFrames";
    homepage = "https://github.com/rapidsai/cudf";
    license = lib.licenses.asl20;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maintainers = [ ];
  };
}
