#!/bin/bash -e

INSTALL=(
  Clone
  Config::IniFiles
  Convert::PEM
  Cookie::Baker::XS
  Crypt::OpenSSL::Bignum
  Crypt::OpenSSL::RSA
  Crypt::OpenSSL::X509
  Crypt::Rijndael
  Crypt::URandom
  DBI
  Digest::HMAC_SHA1
  Digest::MD5
  Digest::SHA
  Email::Sender
  GD::SecurityImage
  HTML::Template
  HTTP::Headers
  HTTP::Request
  IO::String
  JSON
  LWP::UserAgent
  LWP::Protocol::https
  MIME::Base64
  MIME::Entity
  Mouse
  Net::LDAP
  Plack
  Regexp::Assemble
  Regexp::Common
  SOAP::Lite
  String::Random
  Text::Unidecode
  Unicode::String
  URI
  URI::Escape
)

for i in ${INSTALL[@]}; do
  sudo cpan install "$i";
done
