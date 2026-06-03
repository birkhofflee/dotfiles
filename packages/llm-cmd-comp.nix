{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  llm,
  prompt-toolkit,
}:
buildPythonPackage rec {
  pname = "llm-cmd-comp";
  version = "1.2.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "CGamesPlay";
    repo = "llm-cmd-comp";
    rev = "7d49cf7ab3e4571343ac1cac4bf54c8ea0fb8ef4";
    hash = "sha256-0wUM8mJdGB/Y6xs1bYd0VauI8KoTYgbODgJRtCu51XM=";
  };

  build-system = [ setuptools ];

  dependencies = [
    llm
    prompt-toolkit
  ];

  doCheck = false;

  meta = {
    description = "Use LLM to generate commands for your shell";
    homepage = "https://github.com/CGamesPlay/llm-cmd-comp";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
