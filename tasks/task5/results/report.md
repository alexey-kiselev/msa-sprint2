# Задание 5. Настройка управления трафиком с Istio

В Minikube с Istio запущено две версии booking-service (`v1`, `v2`) через Helm.
Включена sidecar-инъекция. Один сервис, разные деплойменты по лейблу `version`. `/ping` - `pong v1` или `pong v2`.

- 90% трафика -> v1, 10% -> v2 (canary)
- Если заголовок `X-Feature-Enabled: true` - весь трафик на v2 (фича-флаг)
- HTTP Retry через VirtualService; подключения и circuit breaking - через DestinationRule
- Fallback: retries в VirtualService (при 5xx/connect-failure повтор может уйти на v2)
- EnvoyFilter на ingress: заголовок `X-Feature-Enabled: true` сразу на кластер v2
