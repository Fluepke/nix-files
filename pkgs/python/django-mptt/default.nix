{
  lib,
  buildPythonPackage,
  fetchPyPi,
  django,
  django-js-asset
}:

buildPythonPackage rec {
  pname = "django-mptt";
  version = "0.12.0";

  buildInputs = [
    django
    django-js-asset
  ];

  src = fetchPyPi {
    inherit pname version;
    sha256 = "1f7hfl9hxw92hdp4fgp94q85pinlsgmmq9lm0ip1x7jzl5j8c3vu";
  };

  meta = with lib; {
    homepage = "https://github.com/django-mptt/django-mptt";
    license = licenses.bsd3;
  };
}
