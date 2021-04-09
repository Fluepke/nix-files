{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  django,
  django-cacheops,
  django-cors-headers,
  django-debug-toolbar,
  django-filter,
  django-mptt,
  django-pglocks,
  django-prometheus,
  django-rq,
  django-tables2,
  django-taggit,
  django-timezone-field,
  djangorestframework,
  drf-yasg,
  gunicorn,
  jinja2,
  markdown,
  netaddr,
  pillow,
  pycryptodome,
  pyyaml,
  svgwrite
}:

buildPythonPackage rec {
  pname = "django-cacheops";
  version = "5.1";

  buildInputs = [
    django
    django-cacheops
    django-cors-headers
    django-debug-toolbar
    django-filter
    django-mptt
    django-pglocks
    django-prometheus
    django-rq
    django-tables2
    django-taggit
    django-timezone-field
    djangorestframework
    drf-yasg
    gunicorn
    jinja2
    markdown
    netaddr
    pillow
    pycryptodome
    pyyaml
    svgwrite
  ];

  src = fetchFromGithub {
    owner = "netbox-community";
    repo = "netbox";
    rev = "e9930854c4716c49d5db73bc6728f891e80929d2";
    sha256 = "1f7hfl9hxw92hdp4fgp94q85pinlsgmmq9lm0ip1x7jzl5j8c3vo";
  };

  meta = with lib; {
    homepage = "https://github.com/netbox-community/netbox";
    license = licenses.bsd3;
  };
}
