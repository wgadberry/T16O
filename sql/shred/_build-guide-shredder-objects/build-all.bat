@echo off
REM ============================================================================
REM T16O Guide Shredder - Windows Build Script
REM ============================================================================
REM Builds all database objects and sets up the environment
REM
REM Usage:
REM   build-all.bat                    (uses defaults)
REM   build-all.bat HOST PORT USER     (custom connection)
REM
REM Defaults: localhost, 3396, root
REM ============================================================================

setlocal

REM Configuration
set DB_HOST=%1
set DB_PORT=%2
set DB_USER=%3
set DB_NAME=t16o_db

if "%DB_HOST%"=="" set DB_HOST=localhost
if "%DB_PORT%"=="" set DB_PORT=3396
if "%DB_USER%"=="" set DB_USER=root

echo.
echo ============================================================
echo T16O Guide Shredder Build
echo ============================================================
echo Host: %DB_HOST%
echo Port: %DB_PORT%
echo User: %DB_USER%
echo Database: %DB_NAME%
echo ============================================================
echo.

REM Prompt for password
set /p DB_PASS=Enter MySQL password:

echo.
echo Building database objects...
echo.

REM Run each build script in order
echo [1/5] Building Schema...
mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASS% %DB_NAME% < 01-schema\build-schema.sql
if %ERRORLEVEL% neq 0 (
    echo ERROR: Schema build failed
    goto :error
)

echo [2/5] Building Functions...
mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASS% %DB_NAME% < 02-functions\build-functions.sql
if %ERRORLEVEL% neq 0 (
    echo ERROR: Functions build failed
    goto :error
)

echo [3/5] Building Procedures...
mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASS% %DB_NAME% < 03-procedures\build-procedures.sql
if %ERRORLEVEL% neq 0 (
    echo ERROR: Procedures build failed
    goto :error
)

echo [4/5] Building Views...
mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASS% %DB_NAME% < 04-views\build-views.sql
if %ERRORLEVEL% neq 0 (
    echo ERROR: Views build failed
    goto :error
)

echo [5/5] Loading Reference Data...
mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASS% %DB_NAME% < 05-data\build-data.sql
if %ERRORLEVEL% neq 0 (
    echo ERROR: Reference data load failed
    goto :error
)

echo.
echo ============================================================
echo Database Build Complete!
echo ============================================================
echo.

REM Setup Python environment
echo Setting up Python environment...
echo.

if exist python\requirements.txt (
    echo Installing Python dependencies...
    pip install -r python\requirements.txt
    if %ERRORLEVEL% neq 0 (
        echo WARNING: Python dependencies installation had issues
    ) else (
        echo Python dependencies installed successfully
    )
) else (
    echo WARNING: requirements.txt not found
)

echo.
echo ============================================================
echo Setup RabbitMQ Queues?
echo ============================================================
set /p SETUP_RABBIT=Setup RabbitMQ queues? (y/n):
if /i "%SETUP_RABBIT%"=="y" (
    echo Setting up RabbitMQ queues...
    python 06-rabbitmq\setup-queues.py
    if %ERRORLEVEL% neq 0 (
        echo WARNING: RabbitMQ setup had issues
    ) else (
        echo RabbitMQ queues created successfully
    )
)

echo.
echo ============================================================
echo Build Complete!
echo ============================================================
echo.
echo Next steps:
echo   1. Start RabbitMQ consumer: python python\shredder-guide.py
echo   2. Feed signatures: python python\guide-producer.py ^<address^>
echo   3. Run analytics: python python\guide-analytics.py
echo.

goto :end

:error
echo.
echo ============================================================
echo BUILD FAILED
echo ============================================================
echo Please check the error messages above.
echo.
exit /b 1

:end
endlocal
