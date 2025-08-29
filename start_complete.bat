@echo off
echo ===============================================
echo    🏥 Swasthya AI - Medical Prescription System
echo ===============================================
echo.
echo 🔧 System Check...

REM Check if FFmpeg is available
ffmpeg -version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ FFmpeg not found! Installing...
    echo    Please allow the installation when prompted.
    winget install FFmpeg
    echo    ✅ FFmpeg installed. Please restart this script.
    pause
    exit /b 1
) else (
    echo ✅ FFmpeg is available
)

REM Check if Python virtual environment exists
if not exist ".venv\Scripts\python.exe" (
    echo ❌ Virtual environment not found!
    echo    Please run: python -m venv .venv
    pause
    exit /b 1
) else (
    echo ✅ Virtual environment found
)

REM Check if required packages are installed
.venv\Scripts\python.exe -c "import fastapi, uvicorn, whisper" >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Required packages not found! Installing...
    .venv\Scripts\pip.exe install -r requirements.txt
    echo ✅ Packages installed
) else (
    echo ✅ Required packages available
)

echo.
echo 🚀 Starting Swasthya AI Backend Server...
echo    📡 Server: http://localhost:8000
echo    📋 API Docs: http://localhost:8000/docs
echo    🌐 Frontend: Open ai-chat.html in browser
echo.
echo 💡 To stop server: Press Ctrl+C
echo ===============================================
echo.

REM Start the server
.venv\Scripts\python.exe main.py --server --port 8000

echo.
echo 🔄 Server stopped.
pause
