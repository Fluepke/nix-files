{
  lib,
  buildPythonPackage,
  fetchPyPi,
  django,
  rq,
  redis
}:

buildPythonPackage rec {
  pname = "django-rq";
  version = "2.4.0";

  buildInputs = [
    django
    rq
    redis
  ];

  src = fetchPyPi {
    inherit pname version;
    sha256 = "1f7hfl9hxw92hdp4fgp94q85pinlsgmmq9lm0ip1x7jzl5j8c3vo";
  };

  meta = with lib; {
    homepage = "https://github.com/rq/django-rq";
    license = licenses.bsd3;
  };
}
