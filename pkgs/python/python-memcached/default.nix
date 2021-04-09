{
  lib,
  buildPythonPackage,
  fetchPyPi,
  six
}:

buildPythonPackage rec {
  pname = "python-memcached";
  version = "1.59";

  buildInputs = [
    six
  ];

  src = fetchPyPi {
    inherit pname version;
    sha256 = "1f7hfl9hxw92hdp4fgp94q85pinlsgmmq9lm0ip1x7jzl5j8c3vo";
  };

  meta = with lib; {
    homepage = "https://github.com/linsomniac/python-memcached";
    license = licenses.bsd3;
  };
}
