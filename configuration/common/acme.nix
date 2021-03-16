{ config, ... }:

{
  security.acme = {
    email = "acme@fluep.ke";
    acceptTerms = true;
  };
}
