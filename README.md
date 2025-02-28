# Docker + Kubernetes Deployment

## Описание проекта
Этот репозиторий содержит:
- Docker-образ, который запускает web-сервер на порту 8000 и раздаёт файлы из директории `/app`.
- Kubernetes-манифесты для деплоя образа, включая:
  - Пробы работоспособности и готовности.
  - Ограничения по ресурсам.
- Helm-чарт для упрощённого развёртывания.
- CI/CD скрипт для автоматической сборки и деплоя в Kubernetes.
- Инструкции по проверке работоспособности сервиса.
- Методы обновления всех деплойментов с именем, содержащим `test`.
- Анализ восстановления pod'ов из `kube-system` после удаления.

## Развёртывание

### Сборка Docker-образа
```sh
docker build -t honorwizz/webserverhtml:latest .
docker push honorwizz/webserverhtml:latest
```

### Развёртывание в Kubernetes
```sh
kubectl apply -f k8s/
```

### Установка через Helm
```sh
helm install web-server .
```

## Проверка работоспособности запущенного приложения
Существует несколько способов проверить, работает ли приложение:
1. **Проверить статус подов**
   ```sh
   kubectl get pods -o wide
   ```
   Если поды находятся в статусе `Running`, это означает, что контейнеры запущены и работают.

2. **Просмотреть логи приложения**
   ```sh
   kubectl logs <pod_name>
   ```
   Логи могут помочь определить ошибки или проблемы при запуске.

3. **Перенаправление порта и локальная проверка**
   ```sh
   kubectl port-forward <pod_name> 8000:8000
   curl http://localhost:8000/test.html
   ```
   Этот способ позволяет проверить доступность веб-приложения локально.

4. **Проверка состояния через liveness и readiness пробы**
   ```sh
   kubectl describe pod <pod_name>
   ```
   В разделе `Events` можно увидеть, успешно ли проходят проверки работоспособности.

## Обновление всех деплойментов с `test`
Для одновременного обновления всех деплойментов, содержащих `test` в названии, можно использовать следующую команду:
```sh
kubectl rollout restart deployment -l name=test
```
Эта команда выполнит перезапуск всех подов в соответствующих деплойментах без простоя сервиса.

## Удаление pod'ов из `kube-system`
Удалить все поды в `kube-system` можно командой:
```sh
kubectl delete pod -n kube-system --all
```
### Почему pod'ы восстанавливаются?
- **CoreDNS** – управляется `Deployment`, поэтому контроллер автоматически пересоздаёт удалённые поды.
- **Kube-apiserver** – это static pod, управляемый `kubelet`. Он не управляется `Deployment` или `ReplicaSet`, а запускается непосредственно через файлы манифестов в `/etc/kubernetes/manifests/`. После удаления kubelet обнаруживает отсутствие пода и создаёт его заново.

## CI/CD
Автоматическая сборка и деплой реализованы с помощью GitHub Actions.

### Сылка на Docker Hub

https://hub.docker.com/r/honorwizz/webserverhtml
