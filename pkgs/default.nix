{ pkgs, ... }:

let
  callPackage = pkgs.lib.callPackageWith(pkgs // custom );
  custom = {
    prometheus-f2b-exporter = callPackage ./prometheus-f2b-exporter {};
    prometheus-ios-exporter = callPackage ./prometheus-ios-exporter {};
    prometheus-iperf3-exporter = callPackage ./prometheus-iperf3-exporter {};
    prometheus-iptables-exporter = callPackage ./prometheus-iptables-exporter {};
    prometheus-smokeping-exporter = callPackage ./prometheus-smokeping-exporter {};
    prometheus-vodafone-station-exporter = callPackage ./prometheus-vodafone-station-exporter {};
    prometheus-zyxel-exporter = callPackage ./prometheus-zyxel-exporter {};
    prometheus-tc4400-exporter = callPackage ./prometheus-tc4400-exporter {};
#    python3 = pkgs.python3.override {
#      packageOverrides = python3-self: python3-super: {
#        django-cacheops = python3-self.callPackage ./python/django-cacheops {};
#        django-cors-headers = python3-super.django-cors-headers.overridePythonAttrs (oA: rec {
#          version = "3.7.0";
#          src = python3-super.fetchPyPi {
#            pname = "django-cors-headers";
#            inherit version;
#            sha256 = "1f7hfl9hxw92hdp4fgp94q85pinlsgmmq9lm0ip1x7jzl5j8c3vi";
#          };
#        });
#        django-debug-toolbar = python3-self.callPackage ./python/django-debug-toolbar;
#        django-mptt = python3-self.callPackage ./python/django-mptt;
#        django-js-asset = python3-self.callPackage ./python/django-js-asset;
#        django-prometheus = python3-self.callPackage ./python/django-prometheus;
#        django-redis = python3-self.callPackage ./python/django-redis;
#        pip-prometheus = python3-self.callPackage ./python/pip-prometheus;
#        python-memcached = python3-self.callPackage ./python/python-memcached;
#        django-rq = python3-self.callPackage ./python/django-rq;
#        django-tables2 = python3-self.callPackage ./python/django-tables2;
#        django-taggit = python3-self.callPackage ./python/django-taggit;
#        django-timezone-field = python3-self.callPackage ./python/django-timezone-field;
#        djangorestframework = python3-self.callPackage ./python/djangorestframework;
#        jinja2 = python3-super.jinja2.overridePythonAttrs (oA: rec {
#          version = "2.11.3";
#          src = python3-super.fetchPyPi {
#            pname = "Jinja2";
#            inherit version;
#            sha256 = "1f7hfl9hxw92hdp4fgp94q85pinlsgmmq9lm0ip1x7jzl5j8c3vo";
#          };
#        });
#        markdown = python3-super.markdown.overridePythonAttrs (oA: rec {
#          version = "3.3.4";
#          src = python3-super.fetchPyPi {
#            pname = "Markdown";
#            inherit version;
#            sha256 = "1f7hfl9hxw92hdp4fgp94q85pinlsgmmq9lm0ip1x7jzl5j8c3vo";
#          };
#        });
#        pillow = python3-super.pillow.overridePythonAttrs (oA: rec {
#          version = "8.1.2";
#          src = python3-super.fetchPyPi {
#            pname = "Pillow";
#            inherit version;
#            sha256 = "1f7hfl9hxw92hdp4fgp94q85pinlsgmmq9lm0ip1x7jzl5j8c3vo";
#          };
#        });
#        pycryptodome = python3-super.pycryptodome.overridePythonAttrs (oA: rec {
#          version = "3.10.1";
#          src = python3-super.fetchPyPi {
#            pname = "pycryptodome";
#            inherit version;
#            sha256 = "1f7hfl9hxw92hdp4fgp94q85pinlsgmmq9lm0ip1x7jzl5j8c3vo";
#          };
#        });
#        pyyaml = python3-super.pyyaml.overridePythonAttrs (oA: rec {
#          version = "5.4.1";
#          src = python3-super.fetchPyPi {
#            pname = "PyYAML";
#            inherit version;
#            sha256 = "1f7hfl9hxw92hdp4fgp94q85pinlsgmmq9lm0ip1x7jzl5j8c3vo";
#          };
#        });
#        svgwrite = python3-super.svgwrite.overridePythonAttrs (oA: rec {
#          version = "1.4.1";
#          src = python3-super.fetchPyPi {
#            pname = "svgwrite";
#            inherit version;
#            sha256 = "1f7hfl9hxw92hdp4fgp94q85pinlsgmmq9lm0ip1x7jzl5j8c3vo";
#          };
#        });
#      };
#    };
#    netbox = custom.python3.pkgs.callPackage ./python/netbox {};
  };
in custom
