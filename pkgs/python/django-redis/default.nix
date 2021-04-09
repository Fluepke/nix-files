{
  lib,
  buildPythonPackage,
  fetchPyPi,
  django,
  redis,
}:

buildPythonPackage rec {
  pname = "django-redis";
  version = "4.12.1";

  buildInputs = [
    django
    redis
  ];

  src = fetchPyPi {
    inherit pname version;
    sha256 = "1f7hfl9hxw92hdp4fgp94q85pinlsgmmq9lm0ip1x7jzl5j8c3vo";
  };

  meta = with lib; {
    homepage = "https://github.com/jazzband/django-redis";
    license = licenses.bsd3;
  };
}
