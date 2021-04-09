{
  lib,
  buildPythonPackage,
  fetchPyPi,
  django,
  sqlparse
}:

buildPythonPackage rec {
  pname = "django-debug-toolbar";
  version = "3.2";

  buildInputs = [
    django
    sqlparse
  ];

  src = fetchPyPi {
    inherit pname version;
    sha256 = "1f7hfl9hxw92hdp4fgp94q85pinlsgmmq9lm0ip1x7jzl5j8c3vu";
  };

  meta = with lib; {
    homepage = "https://github.com/jazzband/django-debug-toolbar";
    license = licenses.bsd3;
  };
}
