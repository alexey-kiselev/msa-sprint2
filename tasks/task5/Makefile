IMAGE_NAME=booking-service
IMAGE_TAG=latest

.PHONY: ci istio deploy checks

ci:
	gitlab-ci-local --force-shell-executor build test deploy tag

istio:
	kubectl label namespace default istio-injection=enabled --overwrite
	kubectl apply -f ./istio/

deploy:
	helm upgrade --install booking-service-v1 ./helm/booking-service -f ./helm/booking-service/values-v1.yaml --wait --timeout 3m
	helm upgrade --install booking-service-v2 ./helm/booking-service -f ./helm/booking-service/values-v2.yaml --wait --timeout 3m
	kubectl apply -f ./istio/

checks:
	./check-all.sh
