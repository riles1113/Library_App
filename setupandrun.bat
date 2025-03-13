@echo off
setlocal EnableDelayedExpansion

echo Starting LibraryApp Setup...

:: Set project directory
set "PROJECT_DIR=%CD%\LibraryApp"
set "CLIENT_DIR=%PROJECT_DIR%\client"
set "SERVER_DIR=%PROJECT_DIR%\server"

:: Check for Node.js
echo Checking for Node.js...
node -v >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo Node.js is already installed.
    set "NODE_VERSION="
    for /f "tokens=*" %%i in ('node -v') do set "NODE_VERSION=%%i"
    echo Found %NODE_VERSION%
) else (
    echo Node.js not found. Downloading and installing...
    curl -o node_installer.msi https://nodejs.org/dist/v20.11.1/node-v20.11.1-x64.msi
    if exist node_installer.msi (
        msiexec /i node_installer.msi /quiet /norestart
        echo Node.js installed. Please restart this script after system PATH updates.
        pause
        exit /b
    ) else (
        echo Failed to download Node.js. Please install manually from https://nodejs.org/
        pause
        exit /b
    )
)

:: Check for npm (comes with Node.js)
echo Checking for npm...
npm -v >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo npm not found despite Node.js installation. Please reinstall Node.js.
    pause
    exit /b
)

:: Check for MongoDB
echo Checking for MongoDB...
mongod --version >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo MongoDB is already installed.
) else (
    echo MongoDB not found. Downloading and installing...
    curl -o mongodb.zip https://fastdl.mongodb.org/windows/mongodb-windows-x86_64-7.0.6.zip
    if exist mongodb.zip (
        powershell -Command "Expand-Archive -Path mongodb.zip -DestinationPath %PROGRAMFILES%\MongoDB"
        ren "%PROGRAMFILES%\MongoDB\mongodb-windows-x86_64-7.0.6" "Server"
        mkdir "%PROGRAMFILES%\MongoDB\Server\data"
        setx PATH "%PATH%;%PROGRAMFILES%\MongoDB\Server\bin" /M
        echo MongoDB installed. Starting mongod...
        start "" "%PROGRAMFILES%\MongoDB\Server\bin\mongod.exe" --dbpath "%PROGRAMFILES%\MongoDB\Server\data"
    ) else (
        echo Failed to download MongoDB. Please install manually from https://www.mongodb.com/try/download/community
        pause
        exit /b
    )
)

:: Create project structure
echo Setting up project structure...
if not exist "%PROJECT_DIR%" mkdir "%PROJECT_DIR%"
if not exist "%CLIENT_DIR%" mkdir "%CLIENT_DIR%"
if not exist "%SERVER_DIR%" mkdir "%SERVER_DIR%"
if not exist "%CLIENT_DIR%\src" mkdir "%CLIENT_DIR%\src"
if not exist "%CLIENT_DIR%\src\components" mkdir "%CLIENT_DIR%\src\components"
if not exist "%SERVER_DIR%\models" mkdir "%SERVER_DIR%\models"
if not exist "%SERVER_DIR%\routes" mkdir "%SERVER_DIR%\routes"

:: Check if user has saved the code files
echo Verifying code files...
set "MISSING_FILES="
for %%f in (
    "%SERVER_DIR%\server.js"
    "%SERVER_DIR%\models\User.js"
    "%SERVER_DIR%\models\Queue.js"
    "%SERVER_DIR%\routes\api.js"
    "%CLIENT_DIR%\src\App.js"
    "%CLIENT_DIR%\src\components\LibraryList.js"
    "%CLIENT_DIR%\src\components\QueueStatus.js"
    "%SERVER_DIR%\.env"
) do (
    if not exist "%%f" (
        set "MISSING_FILES=!MISSING_FILES! %%f"
    )
)
if not "!MISSING_FILES!"=="" (
    echo Missing required files:%MISSING_FILES%
    echo Please save the code into the specified filenames and rerun.
    pause
    exit /b
)

:: Install client dependencies
echo Installing React client dependencies...
cd "%CLIENT_DIR%"
echo {"name": "client","version": "1.0.0","dependencies": {"axios": "^1.6.8","react": "^18.2.0","react-dom": "^18.2.0"},"scripts": {"start": "react-scripts start"}} > package.json
npm install --legacy-peer-deps

:: Install server dependencies
echo Installing server dependencies...
cd "%SERVER_DIR%"
echo {"name": "server","version": "1.0.0","dependencies": {"express": "^4.18.2","mongoose": "^8.2.1","axios": "^1.6.8","dotenv": "^16.4.5","cors": "^2.8.5"},"scripts": {"start": "node server.js"}} > package.json
npm install

:: Launch the app
echo Starting the application...
start cmd /k "cd %SERVER_DIR% && npm start"
start cmd /k "cd %CLIENT_DIR% && npm start"

echo Setup complete! Server running on http://localhost:5000, Client on http://localhost:3000
pause