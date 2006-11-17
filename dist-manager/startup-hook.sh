mkdir -p "@distDir@"
mkdir -p "@distConfDir@"
if ! test -e "@distConfDir@/upload_passwords"; then
    touch "@distConfDir@/upload_passwords"
fi
