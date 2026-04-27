# Devopstrio 12-Factor Scanner - Runtime Bundle
FROM python:3.11-slim

LABEL maintainer="Devopstrio <info@devopstrio.co.uk>"
LABEL org.opencontainers.image.source="https://github.com/devopstrio/12-factor-app-scanner"

WORKDIR /app

# Copy source
COPY src/ /app/src/

# Entrypoint setup
RUN chmod +x /app/src/scanner.py
ENTRYPOINT ["python", "/app/src/scanner.py"]
CMD ["/workspace"]
