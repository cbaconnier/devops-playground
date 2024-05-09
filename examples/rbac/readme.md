Test the access

kubectl exec -ti pod-default -- sh
apk add --update curl
TOKEN=$(cat /run/secrets/kubernetes.io/serviceaccount/token)
curl -H "Authorization: Bearer $TOKEN" https://kubernetes/api/v1/ --insecure
curl -H "Authorization: Bearer $TOKEN" https://kubernetes/api/v1/services --insecure
curl -H "Authorization: Bearer $TOKEN" https://kubernetes/api/v1/pods --insecure
