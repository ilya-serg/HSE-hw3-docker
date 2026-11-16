# HW3 Docker — 4 балла

## Сборка
    docker build -t counter-app .

## Запуск
    docker run -d --name counter -p 8080:8000 -e GREETING="Hello from WSL" counter-app

## Проверка
    curl http://127.0.0.1:8080/
    curl -X POST http://127.0.0.1:8080/increment
    docker logs counter

Результаты проверок — `checks.txt`, логи — `logs.txt`.
