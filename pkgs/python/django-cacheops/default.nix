{
  lib,
  buildPythonPackage,
  fetchPyPi,
  django,
  redis,
  funcy,
  six
}:

buildPythonPackage rec {
  pname = "django-cacheops";
  version = "5.1";

  buildInputs = [
    django
    redis
    funcy
    six
  ];

  src = fetchPyPi {
    inherit pname version;
    sha256 = "1f7hfl9hxw92hdp4fgp94q85pinlsgmmq9lm0ip1x7jzl5j8c3vo";
  };

  meta = with lib; {
    homepage = "https://github.com/Suor/django-cacheops";
    license = licenses.bsd3;
  };
}
