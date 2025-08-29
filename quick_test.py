"""
Simple test to verify the API is working after FFmpeg installation
"""
import requests
import json
import time

API_BASE_URL = "http://localhost:8000"

def test_server():
    """Quick test to verify server is responding"""
    try:
        print("🧪 Testing Swasthya AI API...")
        
        # Test health check
        response = requests.get(f"{API_BASE_URL}/", timeout=5)
        if response.status_code == 200:
            print("✅ Health Check: PASS")
            print(f"   Response: {response.json()}")
        else:
            print(f"❌ Health Check: FAIL (Status: {response.status_code})")
            return False
        
        # Test text prescription
        test_data = {"text": "I am 25 years old male with headache and fever for 2 days"}
        response = requests.post(
            f"{API_BASE_URL}/text-prescription",
            headers={"Content-Type": "application/json"},
            json=test_data,
            timeout=30
        )
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Text Prescription: PASS")
            print(f"   Entities found: {len(result.get('entities', {}).get('symptoms', []))} symptoms")
            print(f"   Prescription generated: {'prescription' in result}")
            if result.get('prescription', {}).get('medications'):
                print(f"   Medications: {len(result['prescription']['medications'])}")
        else:
            print(f"❌ Text Prescription: FAIL (Status: {response.status_code})")
            print(f"   Error: {response.text}")
            return False
        
        print("\n🎉 All tests passed! Your API is working correctly.")
        print("🎙 Voice processing should now work with FFmpeg installed.")
        print("🌐 Try the frontend at: ai-chat.html")
        return True
        
    except requests.exceptions.ConnectionError:
        print("❌ Cannot connect to server. Make sure it's running at http://localhost:8000")
        return False
    except Exception as e:
        print(f"❌ Test failed: {str(e)}")
        return False

if __name__ == "__main__":
    test_server()
