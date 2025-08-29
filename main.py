import whisper
import re
import json
import requests
import sys
import os
import argparse
from typing import Dict, List, Optional, Any
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import uvicorn
import tempfile
import shutil

# --- CONFIGURATION ---
# API Key is now hardcoded directly in the script.
API_KEY = "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"
API_URL = "https://openrouter.ai/api/v1/chat/completions"
MODEL = "openai/gpt-3.5-turbo" # Using a reliable model

# Initialize FastAPI app
app = FastAPI(title="Swasthya AI Backend", description="Medical prescription API with voice processing")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your frontend domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ==============================================================================
# STEP 1: SPEECH-TO-TEXT MODULE (from whisper_stt.py)
# ==============================================================================

def transcribe_audio(audio_path: str) -> str:
    """
    Transcribes an audio file to text using OpenAI Whisper.
    """
    print(" whisper model is base , if you want to use other model change it in code itself ")
    print("🎙 Loading Whisper model and transcribing audio...")
    if not os.path.exists(audio_path):
        error_msg = f"❌ Error: Audio file not found at '{audio_path}'"
        print(error_msg)
        raise FileNotFoundError(error_msg)
        
    try:
        model = whisper.load_model("base")
        result = model.transcribe(audio_path, fp16=False) # fp16=False can improve compatibility
        print("✅ Transcription complete.")
        return result["text"]
    except FileNotFoundError as e:
        if "ffmpeg" in str(e).lower() or "system cannot find the file specified" in str(e):
            error_msg = "❌ FFmpeg is required but not found. Please install FFmpeg and restart your terminal/server."
            print(error_msg)
            raise Exception(error_msg)
        else:
            error_msg = f"❌ File not found error during transcription: {e}"
            print(error_msg)
            raise Exception(error_msg)
    except Exception as e:
        error_msg = f"❌ Error during transcription: {e}"
        print(error_msg)
        raise Exception(error_msg)


# ==============================================================================
# STEP 2: ENTITY EXTRACTION MODULE (from entity_extractor.py)
# ==============================================================================

class MedicalEntityExtractor:
    """Extract medical entities from patient voice note transcripts."""
    
    def __init__(self):
        self.symptoms_list = [
            "fever", "headache", "cough", "body pain", "fatigue", "nausea", 
            "vomiting", "diarrhea", "constipation", "dizziness", "chest pain",
            "back pain", "stomach pain", "sore throat", "runny nose", 
            "stuffy nose", "shortness of breath", "weakness", "joint pain",
            "muscle pain", "chills", "sweating", "rash", "itching", "swelling"
        ]
        self.age_patterns = [r'(\d{1,3})\s*year[s]?\s*old', r'I\'?m\s*(\d{1,3})', r'age\s*is\s*(\d{1,3})']
        self.gender_patterns = [r'\b(male|man|boy)\b', r'\b(female|woman|girl|lady)\b']
        self.duration_patterns = [r'(for|since|last|past)\s+((?:\d+|a|an|few)\s+(?:day|week|month|year)s?)']

    def extract_entities(self, transcript: str) -> Dict[str, Any]:
        """Extract all medical entities from a patient transcript."""
        print("🔍 Extracting key medical entities...")
        
        age = self._extract_with_patterns(transcript, self.age_patterns)
        gender = self._extract_gender(transcript)
        symptoms = self._extract_symptoms(transcript)
        duration = self._extract_with_patterns(transcript, self.duration_patterns, group_index=0)

        entities = {
            "age": int(age) if age and age.isdigit() else None,
            "gender": gender,
            "symptoms": symptoms,
            "duration": duration
        }
        print("✅ Entity extraction complete.")
        return entities

    def _extract_with_patterns(self, text: str, patterns: List[str], group_index: int = 1) -> Optional[str]:
        for pattern in patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                return match.group(group_index).strip()
        return None

    def _extract_gender(self, text: str) -> Optional[str]:
        text_lower = text.lower()
        if re.search(self.gender_patterns[0], text_lower):
            return 'male'
        if re.search(self.gender_patterns[1], text_lower):
            return 'female'
        return None

    def _extract_symptoms(self, text: str) -> List[str]:
        text_lower = text.lower()
        found = {symptom for symptom in self.symptoms_list if re.search(r'\b' + symptom + r'\b', text_lower)}
        return list(found)


# ==============================================================================
# STEP 3: PRESCRIPTION GENERATION MODULE (from prescription_generator.py)
# ==============================================================================

class PrescriptionAI:
    """Clinqo-AI prescription suggestion system (simulation only)"""
    
    def __init__(self, api_key: str):
        self.api_key = api_key
    
    def generate_prescription(self, patient_info: Dict[str, Any]) -> Dict[str, Any]:
        """Generates a simulated prescription using an LLM."""
        print("🤖 Calling AI to generate clinical assessment...")
        
        prompt = self._build_prompt(patient_info)
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json",
        }
        data = {
            "model": MODEL,
            "messages": [{"role": "user", "content": prompt}],
            "response_format": {"type": "json_object"} # For models that support JSON mode
        }
        
        try:
            response = requests.post(API_URL, headers=headers, json=data, timeout=45)
            response.raise_for_status() # Raises an HTTPError for bad responses (4xx or 5xx)
            
            content = response.json()['choices'][0]['message']['content']
            print("✅ AI assessment generated successfully.")
            return json.loads(content)
            
        except requests.exceptions.RequestException as e:
            print(f"❌ API Request Failed: {e}")
            return {"error": str(e), "details": response.text if 'response' in locals() else "No response"}
        except (json.JSONDecodeError, KeyError) as e:
            print(f"❌ Failed to parse AI response: {e}")
            return {"error": "Invalid JSON response from AI", "raw_content": content if 'content' in locals() else "No content"}

    def _build_prompt(self, patient_info: Dict[str, Any]) -> str:
        """Constructs the prompt for the LLM."""
        symptoms_text = ", ".join(patient_info.get("symptoms", ["not specified"])) or "not specified"
        
        return f"""
        Analyze the following patient data and generate a simulated medical assessment.
        
        Patient Information:
        - Age: {patient_info.get("age", "not specified")}
        - Gender: {patient_info.get("gender", "not specified")}
        - Symptoms: {symptoms_text}
        - Duration: {patient_info.get("duration", "not specified")}

        Generate your response in this EXACT JSON format. Do not include any text outside the JSON object.

        {{
          "clinical_summary": "A brief assessment of the patient's condition based on the symptoms.",
          "possible_diagnoses": ["Most likely condition", "Alternative possibility 1", "Alternative possibility 2"],
          "confidence_score": "A float between 0.0 and 1.0 indicating confidence in the primary diagnosis.",
          "medications": [
            {{
              "medicine_name": "[SIMULATED] Medicine Name",
              "dosage": "e.g., 500mg",
              "frequency": "e.g., Twice daily", 
              "duration": "e.g., 7 days",
              "instructions": "e.g., Take with food."
            }}
          ],
          "recommended_tests": ["List any recommended diagnostic tests, e.g., 'Blood Test (CBC)'."],
          "lifestyle_advice": ["Provide 2-3 brief, actionable lifestyle or self-care recommendations."],
          "disclaimer": "This is an AI-generated simulation for educational purposes only. It is not a substitute for professional medical advice."
        }}
        """

# ==============================================================================
# FASTAPI ENDPOINTS
# ==============================================================================

@app.get("/")
async def root():
    """Health check endpoint"""
    return {"message": "Swasthya AI Backend is running!", "status": "healthy"}

@app.post("/process-voice")
async def process_voice(audio_file: UploadFile = File(...)):
    """
    Process uploaded voice recording and return prescription
    """
    try:
        # Validate file type
        if not audio_file.content_type.startswith('audio/'):
            raise HTTPException(status_code=400, detail="File must be an audio file")
        
        # Create temporary file
        with tempfile.NamedTemporaryFile(delete=False, suffix=".mp3") as temp_file:
            shutil.copyfileobj(audio_file.file, temp_file)
            temp_path = temp_file.name
        
        try:
            # Step 1: Transcribe Audio
            print(f"🎙 Processing audio file: {audio_file.filename}")
            transcript = transcribe_audio(temp_path)
            print(f"📋 Transcript: {transcript}")

            # Step 2: Extract Entities
            extractor = MedicalEntityExtractor()
            entities = extractor.extract_entities(transcript)
            print(f"🧩 Entities: {entities}")

            # Step 3: Generate Prescription
            ai_prescriber = PrescriptionAI(api_key=API_KEY)
            prescription = ai_prescriber.generate_prescription(entities)
            print(f"🩺 Prescription generated")

            return JSONResponse(content={
                "success": True,
                "transcript": transcript,
                "entities": entities,
                "prescription": prescription,
                "message": "Voice processed successfully"
            })
            
        finally:
            # Clean up temporary file
            if os.path.exists(temp_path):
                os.unlink(temp_path)
                
    except Exception as e:
        print(f"❌ Error processing voice: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error processing audio: {str(e)}")

@app.post("/text-prescription")
async def text_prescription(request_data: dict):
    """
    Generate prescription from text input
    """
    try:
        text_input = request_data.get("text", "")
        if not text_input:
            raise HTTPException(status_code=400, detail="Text input is required")
        
        # Step 1: Extract Entities from text
        extractor = MedicalEntityExtractor()
        entities = extractor.extract_entities(text_input)
        print(f"🧩 Entities from text: {entities}")

        # Step 2: Generate Prescription
        ai_prescriber = PrescriptionAI(api_key=API_KEY)
        prescription = ai_prescriber.generate_prescription(entities)
        print(f"🩺 Prescription generated from text")

        return JSONResponse(content={
            "success": True,
            "text": text_input,
            "entities": entities,
            "prescription": prescription,
            "message": "Text processed successfully"
        })
        
    except Exception as e:
        print(f"❌ Error processing text: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error processing text: {str(e)}")

# ==============================================================================
# MAIN WORKFLOW ORCHESTRATOR
# ==============================================================================

def main():
    """
    Main function to run the FastAPI server or the CLI workflow.
    """
    parser = argparse.ArgumentParser(description="Swasthya AI - Medical Prescription System")
    parser.add_argument("--server", action="store_true", help="Run as FastAPI server")
    parser.add_argument("--audio", type=str, help="Path to audio file for CLI processing")
    parser.add_argument("--port", type=int, default=8000, help="Port for FastAPI server")
    args = parser.parse_args()

    if args.server:
        print("🚀 Starting Swasthya AI FastAPI Server...")
        print(f"📡 Server will be available at: http://localhost:{args.port}")
        print("📋 API Documentation at: http://localhost:{args.port}/docs")
        uvicorn.run(app, host="0.0.0.0", port=args.port)
    else:
        # CLI mode - process single audio file
        audio_file = args.audio or r"C:\Users\ADMIN\Desktop\Hackethon\acme\full\HorseRun_acithackathon\voice-recording.mp3"
        
        if not os.path.exists(audio_file):
            print(f"❌ Audio file not found: {audio_file}")
            print("💡 Use --audio <path> to specify a different file")
            print("💡 Use --server to run as API server")
            return

        # --- Execute CLI Workflow ---
        
        # Step 1: Transcribe Audio
        transcript = transcribe_audio(audio_file)
        print("\n" + "="*50)
        print("📋 [STEP 1] TRANSCRIPT:")
        print(f'"{transcript}"')
        print("="*50 + "\n")

        # Step 2: Extract Entities
        extractor = MedicalEntityExtractor()
        entities = extractor.extract_entities(transcript)
        print("\n" + "="*50)
        print("🧩 [STEP 2] EXTRACTED ENTITIES:")
        print(json.dumps(entities, indent=2))
        print("="*50 + "\n")

        # Step 3: Generate Prescription
        ai_prescriber = PrescriptionAI(api_key=API_KEY)
        prescription = ai_prescriber.generate_prescription(entities)
        print("\n" + "="*50)
        print("🩺 [STEP 3] AI-GENERATED ASSESSMENT:")
        print(json.dumps(prescription, indent=2))
        print("="*50 + "\n")


if __name__ == "__main__":
    main()