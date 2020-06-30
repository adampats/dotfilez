# apimg

FROM alpine

RUN \
  apk add bash curl gnupg go jq nmap python3 py3-pip wget && \
  pip3 install awscli speedtest-cli && \
  kubectl_version=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt) && \
  curl -LO https://storage.googleapis.com/kubernetes-release/release/${kubectl_version}/bin/linux/amd64/kubectl && \
  mv ./kubectl /usr/local/bin/kubectl && \
  chmod +x /usr/local/bin/kubectl

CMD ["/bin/bash"]
