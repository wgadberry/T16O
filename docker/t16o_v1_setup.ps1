# T16O V1 Infrastructure Setup Script
# Creates Docker containers with persistent named volumes
# NOTE: Does NOT create database schema - run SQL scripts separately after MySQL is ready

param(
    [switch]$Force  # Remove existing containers and volumes before creating
)

$ErrorActionPreference = "Stop"

# Container configuration
$config = @{
    mysql = @{
        name = "t16o_v1_mysql"
        image = "mysql:8.0"
        port = "3396:3306"
        volume = "t16o_v1_mysql_data:/var/lib/mysql"
        env = @(
            "MYSQL_ROOT_PASSWORD=rootpassword",
            "MYSQL_DATABASE=t16o_db"
        )
        args = "--binlog_expire_logs_seconds=259200"
    }
    rabbitmq = @{
        name = "t16o_v1_rabbitmq"
        image = "rabbitmq:3-management"
        ports = @("5692:5672", "15692:15672")
        volume = "t16o_v1_rabbitmq_data:/var/lib/rabbitmq"
        env = @(
            "RABBITMQ_DEFAULT_USER=admin",
            "RABBITMQ_DEFAULT_PASS=admin123"
        )
    }
    influxdb = @{
        name = "t16o_v1_influxdb"
        image = "influxdb:2.7"
        port = "8086:8086"
        volumes = @(
            "t16o_v1_influxdb_data:/var/lib/influxdb2",
            "t16o_v1_influxdb_config:/etc/influxdb2"
        )
        env = @(
            "DOCKER_INFLUXDB_INIT_MODE=setup",
            "DOCKER_INFLUXDB_INIT_USERNAME=admin",
            "DOCKER_INFLUXDB_INIT_PASSWORD=admin123456",
            "DOCKER_INFLUXDB_INIT_ORG=t16o",
            "DOCKER_INFLUXDB_INIT_BUCKET=metrics",
            "DOCKER_INFLUXDB_INIT_RETENTION=7d",
            "DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=t16o-metrics-token"
        )
    }
}

function Write-Status($message) {
    Write-Host "[T16O-V1] $message" -ForegroundColor Cyan
}

function Remove-ContainerIfExists($name) {
    $exists = docker ps -a --filter "name=$name" --format "{{.Names}}" 2>$null
    if ($exists -eq $name) {
        Write-Status "Stopping and removing $name..."
        docker stop $name 2>$null | Out-Null
        docker rm $name 2>$null | Out-Null
    }
}

function New-VolumeIfNotExists($name) {
    $exists = docker volume ls --filter "name=$name" --format "{{.Name}}" 2>$null
    if ($exists -ne $name) {
        Write-Status "Creating volume $name..."
        docker volume create $name | Out-Null
    } else {
        Write-Status "Volume $name already exists"
    }
}

# Force removal if requested
if ($Force) {
    Write-Status "Force mode: removing existing containers..."
    Remove-ContainerIfExists "t16o_v1_mysql"
    Remove-ContainerIfExists "t16o_v1_rabbitmq"
    Remove-ContainerIfExists "t16o_v1_influxdb"
}

# Create volumes
Write-Status "Creating volumes..."
New-VolumeIfNotExists "t16o_v1_mysql_data"
New-VolumeIfNotExists "t16o_v1_rabbitmq_data"
New-VolumeIfNotExists "t16o_v1_influxdb_data"
New-VolumeIfNotExists "t16o_v1_influxdb_config"

# Check if containers already exist
$existingContainers = docker ps -a --filter "name=t16o_v1" --format "{{.Names}}"
if ($existingContainers -and -not $Force) {
    Write-Host "`nExisting t16o_v1 containers found:" -ForegroundColor Yellow
    $existingContainers | ForEach-Object { Write-Host "  - $_" }
    Write-Host "`nUse -Force to remove and recreate, or start them with:" -ForegroundColor Yellow
    Write-Host "  docker start t16o_v1_mysql t16o_v1_rabbitmq t16o_v1_influxdb" -ForegroundColor White
    exit 0
}

# Create MySQL container
Write-Status "Creating MySQL container..."
$mysqlExists = docker ps -a --filter "name=t16o_v1_mysql" --format "{{.Names}}"
if (-not $mysqlExists) {
    docker run -d `
        --name t16o_v1_mysql `
        -p 3396:3306 `
        -v t16o_v1_mysql_data:/var/lib/mysql `
        -e MYSQL_ROOT_PASSWORD=rootpassword `
        -e MYSQL_DATABASE=t16o_db `
        mysql:8.0 `
        --binlog_expire_logs_seconds=259200 | Out-Null
    Write-Status "MySQL container created on port 3396"
}

# Create RabbitMQ container
Write-Status "Creating RabbitMQ container..."
$rabbitmqExists = docker ps -a --filter "name=t16o_v1_rabbitmq" --format "{{.Names}}"
if (-not $rabbitmqExists) {
    docker run -d `
        --name t16o_v1_rabbitmq `
        -p 5692:5672 `
        -p 15692:15672 `
        -v t16o_v1_rabbitmq_data:/var/lib/rabbitmq `
        -e RABBITMQ_DEFAULT_USER=admin `
        -e RABBITMQ_DEFAULT_PASS=admin123 `
        rabbitmq:3-management | Out-Null
    Write-Status "RabbitMQ container created on ports 5692/15692"
}

# Create InfluxDB container
Write-Status "Creating InfluxDB container..."
$influxExists = docker ps -a --filter "name=t16o_v1_influxdb" --format "{{.Names}}"
if (-not $influxExists) {
    docker run -d `
        --name t16o_v1_influxdb `
        -p 8086:8086 `
        -v t16o_v1_influxdb_data:/var/lib/influxdb2 `
        -v t16o_v1_influxdb_config:/etc/influxdb2 `
        -e DOCKER_INFLUXDB_INIT_MODE=setup `
        -e DOCKER_INFLUXDB_INIT_USERNAME=admin `
        -e DOCKER_INFLUXDB_INIT_PASSWORD=admin123456 `
        -e DOCKER_INFLUXDB_INIT_ORG=t16o `
        -e DOCKER_INFLUXDB_INIT_BUCKET=metrics `
        -e DOCKER_INFLUXDB_INIT_RETENTION=7d `
        -e DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=t16o-metrics-token `
        influxdb:2.7 | Out-Null
    Write-Status "InfluxDB container created on port 8086"
}

# Wait for RabbitMQ to start and configure vhost
Write-Status "Waiting for RabbitMQ to start..."
$attempts = 0
$maxAttempts = 30
while ($attempts -lt $maxAttempts) {
    $ready = docker exec t16o_v1_rabbitmq rabbitmqctl await_startup 2>$null
    if ($LASTEXITCODE -eq 0) { break }
    Start-Sleep -Seconds 2
    $attempts++
}

if ($attempts -lt $maxAttempts) {
    Write-Status "Configuring RabbitMQ vhost and exchanges..."
    docker exec t16o_v1_rabbitmq rabbitmqctl add_vhost t16o 2>$null | Out-Null
    docker exec t16o_v1_rabbitmq rabbitmqctl set_permissions -p t16o admin ".*" ".*" ".*" 2>$null | Out-Null
    docker exec t16o_v1_rabbitmq rabbitmqadmin -u admin -p admin123 -V t16o declare exchange name=rpc.topic type=topic durable=true 2>$null | Out-Null
    docker exec t16o_v1_rabbitmq rabbitmqadmin -u admin -p admin123 -V t16o declare exchange name=tasks.topic type=topic durable=true 2>$null | Out-Null
    Write-Status "RabbitMQ configured with vhost 't16o' and exchanges"
} else {
    Write-Host "Warning: RabbitMQ did not start in time. Configure manually." -ForegroundColor Yellow
}

# Show final status
Write-Host "`n"
Write-Host "========================================" -ForegroundColor Green
Write-Host " T16O V1 Infrastructure Ready" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
docker ps --filter "name=t16o_v1" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
Write-Host ""
Write-Host "Connection Info:" -ForegroundColor Cyan
Write-Host "  MySQL:    localhost:3396 (root/rootpassword)" -ForegroundColor White
Write-Host "  RabbitMQ: localhost:5692 (admin/admin123) | UI: http://localhost:15692" -ForegroundColor White
Write-Host "  InfluxDB: localhost:8086 (admin/admin123456) | Token: t16o-metrics-token" -ForegroundColor White
Write-Host ""
Write-Host "NOTE: If this is a fresh setup, run the database build scripts manually." -ForegroundColor Yellow
