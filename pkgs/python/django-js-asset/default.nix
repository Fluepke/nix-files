{
  lib,
  buildPythonPackage,
  fetchPyPi,
  django,
  coverage,
  pytz
}:

buildPythonPackage rec {
  pname = "django-js-asset";
  version = "1.2.2";

  buildInputs = [
    django
    coverage
    pytz
  ];

  src = fetchPyPi {
    inherit pname version;
    sha256 = "1f7hfl9hxw92hdp4fgp94q85pinlsgmmq9lm0ip1x7jzl5j8c3vo";
  };

  meta = with lib; {
    homepage = "https://github.com/matthiask/django-js-asset/";
    license = licenses.bsd3;
  };
}
