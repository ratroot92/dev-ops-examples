
aws eks --region us-east-1 update-kubeconfig --name burency_eks
# kubectl delete all -n default --all
# kubectl delete all -n kubernetes-dashboard --all
# kubectl delete -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.18"
# kubectl delete -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/high-availability.yaml
# kubectl delete -k /home/asd/Desktop/vaultspay/eks/kubernetes/misc/
# kubectl delete -k /home/asd/Desktop/vaultspay/eks/kubernetes/zookeeper/
# kubectl delete -k /home/asd/Desktop/vaultspay/eks/kubernetes/kafka/
# kubectl delete -f /home/asd/Desktop/vaultspay/microservices/auth-microservice/auth-microservice.yaml
# kubectl delete -f /home/asd/Desktop/vaultspay/microservices/banking-engine/banking-engine.yaml
# kubectl delete -f /home/asd/Desktop/vaultspay/microservices/blockchain-engine/blockchain-engine.yaml
# kubectl delete -f /home/asd/Desktop/vaultspay/microservices/control-panel-service/control-panel-service.yaml
# kubectl delete -f /home/asd/Desktop/vaultspay/microservices/files-management-service/files-management-service.yaml
# kubectl delete -f /home/asd/Desktop/vaultspay/microservices/logs-service/logs-service.yaml
# kubectl delete -f /home/asd/Desktop/vaultspay/microservices/matching-engine/matching-engine.yaml
# kubectl delete -f /home/asd/Desktop/vaultspay/microservices/notifications-service/notifications-service.yaml
# kubectl delete -f /home/asd/Desktop/vaultspay/microservices/streaming-worker/streaming-worker.yaml
# kubectl delete -f /home/asd/Desktop/vaultspay/microservices/user-microservice/user-microservice.yaml



kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.18"
# Run Twice 
kubectl apply -k /home/asd/Desktop/vaultspay/eks/kubernetes/nginx-ingress-controller/

sleep 15
kubectl apply -k /home/asd/Desktop/vaultspay/eks/kubernetes/nginx-ingress-controller/

kubectl apply -f /home/asd/Desktop/vaultspay/eks/kubernetes/misc/cluster-autoscaler.yml
kubectl apply -f /home/asd/Desktop/vaultspay/eks/kubernetes/misc/redis.yml
kubectl apply -f /home/asd/Desktop/vaultspay/eks/kubernetes/misc/mongodb.yml
sleep 15
kubectl apply -k /home/asd/Desktop/vaultspay/eks/kubernetes/misc/
kubectl apply -k /home/asd/Desktop/vaultspay/eks/kubernetes/zookeeper/
## Required for kafka to work  (/home/asd/Desktop/vaultspay/eks/kubernetes/kafka/debug.txt)
kubectl create clusterrolebinding fixRBACKafka --clusterrole=cluster-admin --serviceaccount=default:default
kubectl apply -k /home/asd/Desktop/vaultspay/eks/kubernetes/kafka/
kubectl apply -f /home/asd/Desktop/vaultspay/microservices/auth-microservice/auth-microservice.yaml
kubectl apply -f /home/asd/Desktop/vaultspay/microservices/banking-engine/banking-engine.yaml
kubectl apply -f /home/asd/Desktop/vaultspay/microservices/blockchain-engine/blockchain-engine.yaml
kubectl apply -f /home/asd/Desktop/vaultspay/microservices/control-panel-service/control-panel-service.yaml
kubectl apply -f /home/asd/Desktop/vaultspay/microservices/files-management-service/files-management-service.yaml
kubectl apply -f /home/asd/Desktop/vaultspay/microservices/logs-service/logs-service.yaml
kubectl apply -f /home/asd/Desktop/vaultspay/microservices/matching-engine/matching-engine.yaml
kubectl apply -f /home/asd/Desktop/vaultspay/microservices/notifications-service/notifications-service.yaml
kubectl apply -f /home/asd/Desktop/vaultspay/microservices/streaming-worker/streaming-worker.yaml
kubectl apply -f /home/asd/Desktop/vaultspay/microservices/user-microservice/user-microservice.yaml
kubectl apply -f /home/asd/Desktop/vaultspay/eks/kubernetes/misc/redis-commander.yml
watch -n 1 kubectl get all 


# kubectl exec mongo-0 -- mongosh --eval 'rs.initiate(); var cfg = rs.conf(); cfg.members[0].host = "mongo-0.mongo:27017"; rs.reconfig(cfg); rs.add("mongo-1.mongo:27017"); rs.add("mongo-2.mongo:27017"); rs.status(); exit;'
# kubectl get pods -l app=redis-cluster -o jsonpath='{range.items[*]}{.status.podIP}:6379 '
# kubectl exec -it redis-cluster-0 -- redis-cli --cluster create --cluster-replicas 1 10.0.71.121:6379 10.0.104.144:6379 10.0.117.39:6379 10.0.95.65:6379 10.0.110.69:6379 10.0.75.136:6379