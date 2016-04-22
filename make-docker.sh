curl https://github.com/rickalm/docker-tools/raw/master/.docker_functions -so etc/.docker_functions
docker build -t rickalm/hashicorp-serf .
[ "${1}" == "push" ] && docker push rickalm/hashicorp-serf
