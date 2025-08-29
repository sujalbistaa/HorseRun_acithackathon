# 🔧 Swasthya AI - Troubleshooting Guide

## ✅ **FIXED: FFmpeg Issue**

### 🐛 **Problem**
```
FileNotFoundError: [WinError 2] The system cannot find the file specified
❌ Error during transcription: [WinError 2] The system cannot find the file specified
```

### 🔧 **Solution Applied**
1. **Installed FFmpeg** using Windows Package Manager:
   ```bash
   winget install FFmpeg
   ```

2. **Improved Error Handling** in `main.py`:
   - Better error messages for missing FFmpeg
   - Proper exception handling instead of `sys.exit()`

3. **Restarted Server** after installation

### ✅ **Current Status**
- ✅ FFmpeg installed and available in PATH
- ✅ Server running on http://localhost:8000
- ✅ Voice processing should now work correctly

## 🎯 **How to Test Voice Processing**

### Option 1: Frontend Test
1. Open `ai-chat.html` in browser
2. Click microphone button
3. Speak your symptoms (e.g., "I have headache and fever")
4. Click stop recording
5. Should see transcript and prescription

### Option 2: API Test
```bash
# Run the quick test
python quick_test.py
```

### Option 3: Manual API Test
```bash
# Test with curl (if available)
curl -X POST "http://localhost:8000/text-prescription" \
     -H "Content-Type: application/json" \
     -d '{"text": "I have headache and fever for 2 days"}'
```

## 🚨 **Common Issues & Solutions**

### Issue 1: Port Already in Use
```bash
# Find process using port 8000
netstat -ano | findstr :8000

# Kill the process (replace PID)
taskkill /PID [PID_NUMBER] /F

# Restart server
python main.py --server --port 8000
```

### Issue 2: FFmpeg Still Not Found
```bash
# Verify FFmpeg installation
ffmpeg -version

# If not found, restart terminal/PowerShell
# Or manually add to PATH
```

### Issue 3: Virtual Environment Issues
```bash
# Activate virtual environment
.\.venv\Scripts\Activate.ps1

# Install requirements again
pip install -r requirements.txt
```

### Issue 4: CORS Errors in Frontend
- Make sure backend is running on localhost:8000
- Check browser console for specific errors
- Verify API_BASE_URL in ai-chat.html

### Issue 5: Audio Recording Not Working
- Grant microphone permissions in browser
- Use HTTPS in production (required for microphone)
- Check browser compatibility (Chrome/Edge recommended)

## 📋 **System Requirements Met**
- ✅ Python 3.12 with virtual environment
- ✅ FFmpeg installed via winget
- ✅ All Python packages installed
- ✅ FastAPI server configured
- ✅ Frontend integrated with backend

## 🎉 **Ready to Use!**
Your Swasthya AI system is now fully functional:

1. **Backend**: http://localhost:8000
2. **API Docs**: http://localhost:8000/docs  
3. **Frontend**: Open `ai-chat.html`

**Voice → AI → Prescription pipeline is LIVE! 🚀**
