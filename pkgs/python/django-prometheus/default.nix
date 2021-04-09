{
  lib,
  buildPythonPackage,
  fetchPyPi,
  django,
  django-redis,
  black,
  flake8,
  isort,
  prometheus-client,
  pip-prometheus,
  mock,
  mysqlclient,
  psycopg2,
  python-memcached
}:

buildPythonPackage rec {
  pname = "django-cacheops";
  version = "5.1";

  buildInputs = [
    django
    django-redis
    black
    flake8
    isort
    prometheus-client
    pip-prometheus
    mock
    mysqlclient
    psycopg2
    python-memcached
  ];

  src = fetchPyPi {
    inherit pname version;
    sha256 = "1f7hfl9hxw92hdp4fgp94q85pinlsgmmq9lm0ip1x7jzl5j8c3vo";
  };

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/korfuri/django-prometheus";
    license = licenses.bsd3;
  };
}
