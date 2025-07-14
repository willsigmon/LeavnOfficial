from xai_sdk import Client
from xai_sdk.chat import user, system
import os

def test_grok_math():
    api_key = os.getenv("XAI_API_KEY")
    assert api_key, "XAI_API_KEY not set in environment variables."

    client = Client(api_host="api.x.ai", api_key=api_key)
    chat = client.chat.create(model="grok-4-0709", temperature=0)
    chat.append(system("You are a PhD-level mathematician."))
    chat.append(user("What is 2 + 2?"))
    response = chat.sample()
    assert "4" in response.content, f"Unexpected response: {response.content}"

if __name__ == "__main__":
    test_grok_math()
    print("Test passed: Grok returns correct answer for 2 + 2.") 