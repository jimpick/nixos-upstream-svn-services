Steps to create a self-signed SSL certificate:

1. Create private key for CA.

$ openssl genrsa -des3 -out ca.key 1024
[enter a passphrase]

2. Create self-signed CA certificate.

$ openssl req -new -x509 -days 365 -key ca.key -out ca.crt
[enter a passphrase]
[contact info, e.g.,:]
[country: NL]
[province: Utrecht]
[city: Utrecht]
[org: Utrecht University]
[unit: Institute of Information and Computing Sciences]
[common name: Subversion Server]
[address: eelco@cs.uu.nl]

3. Create private key for server.

$ openssl genrsa -des3 -out server.key 1024
[enter another passphrase]

4. Remove the passphrase (to allow unattended startup).

$ mv server.key tmp
$ openssl rsa -in tmp -out server.key
$ rm tmp
$ chmod 400 server.key

5. Create Certificate Signing Request.

$ openssl req -new -key server.key -out server.csr
[same contact info as above, BUT common name should be the host name
(without the port), e.g, svn.cs.uu.nl]
[challenge password / company name: empty]

6. Sign the CSR.

$ ./sign.sh server.csr
[enter CA passphrase]
[say yes, yes]

7. Done: the files server.key and server.crt are used by Apache.
