"""
Test script for Swasthya AI API endpoints
"""
import requests
import json

API_BASE_URL = "http://localhost:8000"

def test_health_check():
    """Test the root endpoint"""
    try:
        response = requests.get(f"{API_BASE_URL}/")
        print("✅ Health Check Response:", response.json())
        return True
    except Exception as e:
        print("❌ Health Check Failed:", str(e))
        return False

def test_text_prescription():
    """Test text-based prescription generation"""
    try:
        test_data = {
            "text": "I am a 25-year-old male experiencing headache and fever for 2 days"
        }
        
        response = requests.post(
            f"{API_BASE_URL}/text-prescription",
            headers={"Content-Type": "application/json"},
            data=json.dumps(test_data)
        )
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Text Prescription Test Passed!")
            print("📋 Transcript:", result.get('text'))
            print("🧩 Entities:", json.dumps(result.get('entities'), indent=2))
            print("🩺 Prescription Generated:", 'prescription' in result)
            return True
        else:
            print(f"❌ Text Prescription Test Failed: {response.status_code}")
            print(response.text)
            return False
            
    except Exception as e:
        print("❌ Text Prescription Test Failed:", str(e))
        return False

def main():
    print("🧪 Testing Swasthya AI API Endpoints...")
    print("="*50)
    
    # Test 1: Health Check
    print("\n1. Testing Health Check Endpoint...")
    health_ok = test_health_check()
    
    # Test 2: Text Prescription
    print("\n2. Testing Text Prescription Endpoint...")
    text_ok = test_text_prescription()
    
    print("\n" + "="*50)
    print(f"✅ Health Check: {'PASS' if health_ok else 'FAIL'}")
    print(f"✅ Text Prescription: {'PASS' if text_ok else 'FAIL'}")
    
    if health_ok and text_ok:
        print("\n🎉 All tests passed! Your API is ready to use.")
        print(f"🌐 Frontend can now connect to: {API_BASE_URL}")
        print("📋 API Documentation: http://localhost:8000/docs")
    else:
        print("\n❌ Some tests failed. Please check the server logs.")

if __name__ == "__main__":
    main()
