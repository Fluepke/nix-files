{
  lib,
  buildPythonPackage,
  fetchurl,
  prometheus_client,
  pip
}:

buildPythonPackage rec {
  pname = "pip-prometheus";
  version = "1.2.1";

  buildInputs = [
    prometheus_client
    pip
  ];

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/c1/df/0b3d5ba693a629991e370e286449be2b81d0534912c6cf090eddb235a138/pip-prometheus-1.2.1.tar.gz"
    sha256 = "1f7hfl9hxw92hdp4fgp94q85pinlsgmmq9lm0ip1x7jzl5j8c3vo";
  };

  meta = with lib; {
    homepage = "https://pypi.org/project/pip-prometheus";
    license = licenses.bsd3;
  };
}
