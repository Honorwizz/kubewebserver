FROM python:3.11-slim

RUN useradd -u 1001 -m appuser

WORKDIR /app

COPY app /app

RUN chown -R 1001:1001 /app

USER 1001

CMD ["python", "-m", "http.server", "8000"]
