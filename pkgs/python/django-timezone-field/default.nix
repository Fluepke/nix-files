{
  lib,
  buildPythonPackage,
  fetchPyPi,
  django,
  pytz
}:

buildPythonPackage rec {
  pname = "django-timezone-field";
  version = "4.1.1";

  buildInputs = [
    django
    pytz
  ];

  src = fetchPyPi {
    inherit pname version;
    sha256 = "1f7hfl9hxw92hdp4fgp94q85pinlsgmmq9lm0ip1x7jzl5j8c3vo";
  };

  meta = with lib; {
    homepage = "";
    license = licenses.bsd3;
  };
}
