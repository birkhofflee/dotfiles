{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  llm,
  mlx-lm,
}:
buildPythonPackage rec {
  pname = "llm-mlx";
  version = "0.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "llm-mlx";
    tag = version;
    hash = "sha256-9SGbvhuNeKgMYGa0ZiOLm+H/JbNpvFWBcUL4De5xO4o=";
  };

  build-system = [ setuptools ];

  dependencies = [
    llm
    mlx-lm
  ];

  doCheck = false;

  meta = {
    description = "LLM plugin for running models using the MLX framework";
    homepage = "https://github.com/simonw/llm-mlx";
    license = lib.licenses.asl20;
    platforms = lib.platforms.darwin;
    maintainers = [ ];
  };
}
