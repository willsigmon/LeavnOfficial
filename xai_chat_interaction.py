from xai_sdk import Client
from xai_sdk.chat import user, system
import os

# Retrieve API key securely from environment
api_key = os.getenv("XAI_API_KEY")
if not api_key:
    raise RuntimeError("XAI_API_KEY not set in environment variables.")

client = Client(
    api_host="api.x.ai",
    api_key=api_key
)

chat = client.chat.create(model="grok-4-0709", temperature=0)
chat.append(system("You are a PhD-level mathematician."))
chat.append(user("What is 2 + 2?"))

response = chat.sample()
print(response.content) 