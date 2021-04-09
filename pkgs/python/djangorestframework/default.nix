{
  lib,
  buildPythonPackage,
  fetchPyPi,
  django,
}:

buildPythonPackage rec {
  pname = "djangorestframework";
  version = "3.12.2";

  buildInputs = [
    django
  ];

  src = fetchPyPi {
    inherit pname version;
    sha256 = "1f7hfl9hxw92hdp4fgp94q85pinlsgmmq9lm0ip1x7jzl5j8c3vo";
  };

  meta = with lib; {
    homepage = "https://www.django-rest-framework.org/";
    license = licenses.bsd3;
  };
}
