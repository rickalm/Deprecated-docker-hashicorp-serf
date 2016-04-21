docker build -t rickalm/hashicorp-serf .
[ "${1}" == "push" ] && docker push rickalm/hashicorp-serf
