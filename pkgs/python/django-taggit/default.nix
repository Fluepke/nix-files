{
  lib,
  buildPythonPackage,
  fetchPyPi,
  django,
}:

buildPythonPackage rec {
  pname = "django-taggit";
  version = "1.3.0";

  buildInputs = [
    django
  ];

  src = fetchPyPi {
    inherit pname version;
    sha256 = "1f7hfl9hxw92hdp4fgp94q85pinlsgmmq9lm0ip1x7jzl5j8c3vo";
  };

  meta = with lib; {
    homepage = "https://github.com/jazzband/django-taggit";
    license = licenses.bsd3;
  };
}
