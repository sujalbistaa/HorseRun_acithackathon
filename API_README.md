# Swasthya AI - Voice-Enabled Medical Prescription System

## 🌟 Overview
Swasthya AI is a comprehensive medical prescription system that processes voice recordings and text inputs to generate AI-powered medical assessments and prescriptions.

## 🚀 Features
- **Voice Recording Processing**: Upload MP3/audio files and get transcriptions
- **AI-Powered Prescriptions**: Generate medical assessments using advanced AI
- **Text Input Support**: Process symptoms via text input
- **Entity Extraction**: Extract medical entities (age, gender, symptoms, duration)
- **RESTful API**: FastAPI backend with automatic documentation
- **Modern Frontend**: Interactive chat interface with voice recording

## 📋 Prerequisites
- Python 3.8 or higher
- Windows OS (for current setup)
- Microphone access (for voice recording)
- Internet connection (for AI API calls)

## 🛠️ Installation & Setup

### 1. Install Dependencies
```bash
# The virtual environment and packages are already set up
# Dependencies include: fastapi, uvicorn, whisper, requests, python-multipart
```

### 2. Start the Backend Server
```bash
# Option 1: Using Python directly
python main.py --server --port 8000

# Option 2: Using the batch file
start_server.bat
```

### 3. Open the Frontend
1. Open `ai-chat.html` in your web browser
2. Make sure you're logged in to access the chat interface
3. The frontend will connect to `http://localhost:8000`

## 🎯 API Endpoints

### Health Check
- **GET** `/` - Server health check
- **Response**: `{"message": "Swasthya AI Backend is running!", "status": "healthy"}`

### Voice Processing
- **POST** `/process-voice` - Upload audio file for processing
- **Parameters**: 
  - `audio_file` (file): MP3/audio file
- **Response**: Transcript, entities, and prescription

### Text Processing
- **POST** `/text-prescription` - Process text input
- **Parameters**: 
  - `text` (string): Medical symptoms/concerns
- **Response**: Entities and prescription

## 💻 Usage

### Frontend Chat Interface
1. **Text Input**: Type symptoms and click "Send"
2. **Voice Input**: Click microphone → speak → click stop → get prescription
3. **View Results**: See formatted prescriptions with:
   - Clinical summary
   - Possible diagnoses
   - Medications with dosage
   - Recommended tests
   - Lifestyle advice

### Direct API Usage
```python
import requests

# Text prescription
response = requests.post(
    "http://localhost:8000/text-prescription",
    json={"text": "I have headache and fever for 2 days"}
)

# Voice prescription (with audio file)
with open("recording.mp3", "rb") as f:
    response = requests.post(
        "http://localhost:8000/process-voice",
        files={"audio_file": f}
    )
```

## 🧪 Testing
Run the test script to verify everything is working:
```bash
python test_api.py
```

## 📱 Frontend Features
- **Real-time Chat**: Interactive conversation with AI
- **Voice Recording**: Browser-based audio recording
- **Formatted Prescriptions**: Professional medical format
- **Responsive Design**: Works on desktop and mobile
- **Authentication**: Integrated with Supabase auth

## ⚙️ Configuration
- **AI Model**: OpenAI GPT-3.5-turbo via OpenRouter
- **Whisper Model**: Base model for speech-to-text
- **API Key**: Configured in `main.py`
- **Server Port**: Default 8000 (configurable)

## 🔒 Security & Disclaimers
- **Medical Disclaimer**: This is for educational purposes only
- **Not a Substitute**: Always consult healthcare professionals
- **Data Privacy**: Audio files are processed locally and temporarily
- **API Security**: Secure your API keys in production

## 🐛 Troubleshooting

### Server Won't Start
1. Check if port 8000 is available
2. Verify Python environment activation
3. Install missing dependencies

### Frontend Can't Connect
1. Ensure backend server is running on localhost:8000
2. Check browser console for CORS errors
3. Verify API_BASE_URL in frontend

### Voice Recording Issues
1. Grant microphone permissions
2. Use HTTPS in production
3. Check browser compatibility

## 📁 File Structure
```
├── main.py              # FastAPI backend server
├── ai-chat.html         # Frontend chat interface
├── requirements.txt     # Python dependencies
├── start_server.bat     # Server startup script
├── test_api.py         # API testing script
├── config.js           # Frontend configuration
└── supabase-config.js  # Authentication configuration
```

## 🎉 Success!
Your Swasthya AI system is now ready! 
- **Backend**: http://localhost:8000
- **API Docs**: http://localhost:8000/docs
- **Frontend**: Open `ai-chat.html` in browser

Enjoy building the future of healthcare technology! 🏥✨
