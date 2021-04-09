{
  lib,
  buildPythonPackage,
  fetchPyPi,
  django,
}:

buildPythonPackage rec {
  pname = "django-tables2";
  version = "2.3.4";

  buildInputs = [
    django
  ];

  src = fetchPyPi {
    inherit pname version;
    sha256 = "1f7hfl9hxw92hdp4fgp94q85pinlsgmmq9lm0ip1x7jzl5j8c3vo";
  };

  meta = with lib; {
    homepage = "https://github.com/jieter/django-tables2/";
    license = licenses.bsd3;
  };
}
