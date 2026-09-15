# Задание 4. Описание изменений

## Микро

Go REST:

- `/ping` -> `pong`
- `/health` -> `{"status":"ok"}`
- `/ready` -> `{"status":"ready"}`
- Фича X (`/feature`, меняет `/`) — если `ENABLE_FEATURE_X=true`

## Helm

Chart с Deployment:

- `values.yaml` — Minikube
- `values-staging.yaml` — 1 реплика, X включена
- `values-prod.yaml` — 2 реплики, X выключена, IfNotPresent

## CI/CD

`.gitlab-ci.yml`: build -> test -> deploy -> tag

Запуск: `make ci`
