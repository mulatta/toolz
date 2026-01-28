{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  # Build dependencies
  setuptools,
  # Runtime dependencies
  scipy,
  scikit-learn,
  numpy,
  # Optional dependencies
  pynndescent,
}:
buildPythonPackage {
  pname = "finch-clust";
  version = "0.2.2-unstable-2024-04-30";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ssarfraz";
    repo = "FINCH-Clustering";
    rev = "e4381448ac6ade1a193a60a4f69ee55046ca3c38";
    hash = "sha256-Ay4KPG2gNxuplLdhPRYf6S29pcAk+eccYzzPxpBPAK4=";
  };

  build-system = [ setuptools ];

  dependencies = [
    scipy
    scikit-learn
    numpy
  ];

  optional-dependencies = {
    # ANN (Approximate Nearest Neighbors) support via PyNNDescent for large datasets
    ann = [ pynndescent ];
  };

  pythonImportsCheck = [ "finch" ];

  meta = {
    description = "Parameter-free fast clustering algorithm using First Integer Neighbor relations";
    longDescription = ''
      FINCH (First Integer Neighbor Clustering Hierarchy) is a parameter-free
      clustering algorithm that stands out for its speed and clustering quality.
      It can optionally use PyNNDescent for approximate nearest neighbor search
      on large datasets.
    '';
    homepage = "https://github.com/ssarfraz/FINCH-Clustering";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
