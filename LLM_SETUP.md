# LLM-Powered UI Playground Setup

## Overview
The Mobile UI Playground now supports LLM-powered natural language processing for creating UI components. Instead of relying on hardcoded prompt mappings, the app can now understand and process complex natural language commands using AI.

## Supported LLM Providers

### 1. OpenAI
- **Models**: GPT-3.5-turbo, GPT-4, GPT-4-turbo
- **API Key**: Get from https://platform.openai.com/api-keys
- **Cost**: Pay-per-use

### 2. Anthropic (Claude)
- **Models**: Claude-3-haiku, Claude-3-sonnet, Claude-3-opus
- **API Key**: Get from https://console.anthropic.com/
- **Cost**: Pay-per-use

### 3. Groq (Fast Inference)
- **Models**: Llama3-8b, Llama3-70b, Mixtral-8x7b
- **API Key**: Get from https://console.groq.com/keys
- **Cost**: Free tier available

## Setup Instructions

### 1. Access Settings
- Open the app
- Tap the settings icon (⚙️) in the top-right corner

### 2. Configure LLM Provider
- Select your preferred provider (OpenAI, Anthropic, or Groq)
- Choose a model from the dropdown
- Enter your API key

### 3. Test Configuration
- Enter a test prompt (e.g., "add a red button")
- Tap "Test" to verify the configuration
- If successful, you'll see the generated JSON structure

### 4. Save Configuration
- Tap "Save Configuration" to store your settings
- The app will now use LLM processing for all prompts

## How It Works

### 1. Intelligent Processing
When you enter a command, the app:
1. Sends your prompt to the configured LLM
2. Receives a structured JSON response
3. Converts the JSON to UI components
4. Falls back to hardcoded mappings if LLM fails

### 2. Supported Commands
The LLM can understand complex variations like:
- "Create a large red button with the text 'Submit'"
- "Add a text field for entering email addresses"
- "Make the background a nice shade of blue"
- "Put a card with some information on the screen"
- "Add a purple container labeled 'Settings Panel'"

### 3. Available Components
- **Buttons**: With custom colors and labels
- **Text Fields**: With custom placeholder text
- **Containers**: With custom colors and labels
- **Text**: With custom colors, sizes, and content
- **Cards**: With custom labels
- **Background**: Color changes
- **Title**: App title changes

## Benefits

### 1. Natural Language Understanding
- No need to remember exact command syntax
- Supports variations and synonyms
- Understands context and intent

### 2. Flexibility
- Easy to add new components
- Supports complex attribute combinations
- Extensible for future features

### 3. Fallback Support
- Works without LLM configuration
- Graceful degradation to hardcoded mappings
- No interruption to existing functionality

## Example Commands

### Basic Commands
- "add a button"
- "change background to blue"
- "create a text field"

### Advanced Commands
- "add a large red button saying 'Click Here'"
- "create a text field with placeholder 'Enter your name'"
- "make a purple container labeled 'User Settings'"
- "add small green text saying 'Success!'"

### Voice Commands
All commands work with speech-to-text:
- Tap the microphone button
- Speak your command naturally
- Watch as the LLM processes and creates components

## Troubleshooting

### Common Issues
1. **API Key Invalid**: Double-check your API key
2. **Network Error**: Check internet connection
3. **Rate Limits**: Wait and try again
4. **Model Unavailable**: Try a different model

### Fallback Behavior
If LLM processing fails, the app automatically falls back to hardcoded mappings, ensuring the app remains functional.

## Privacy & Security
- API keys are stored locally on your device
- Prompts are sent to your chosen LLM provider
- No data is stored on our servers
- You control which provider to use

## Cost Considerations
- OpenAI: ~$0.001-0.03 per request
- Anthropic: ~$0.0008-0.075 per request  
- Groq: Free tier available

Most commands cost less than $0.01 to process.