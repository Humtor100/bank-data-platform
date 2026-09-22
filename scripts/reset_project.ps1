$ErrorActionPreference = "Stop"

Write-Host "Stopping project and deleting volumes..."
docker compose down -v --remove-orphans

Write-Host "Rebuilding clean project..."
docker compose up --build -d

Write-Host ""
Write-Host "Project started."
Write-Host "Airflow: http://localhost:8080"
Write-Host "PostgreSQL for PyCharm: localhost:5433 / bank_db / bank_user / bank_password"
