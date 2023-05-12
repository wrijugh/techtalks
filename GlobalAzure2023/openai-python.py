import os
import requests
import json
import openai

print("enter key")
openai.api_key = input()
openai.api_base = "https://wgopenai.openai.azure.com/" 
openai.api_type = 'azure'
openai.api_version = '2022-12-01' 

deployment_name='wggpt3' 

print('Completion..')
start_phrase = 'Microsoft Azure was announced in '
print(start_phrase)



while start_phrase != 'x':
    response = openai.Completion.create(engine=deployment_name, prompt=start_phrase, max_tokens=600, stop=None)
    print(response['choices'][0]['text'])

    print("\r\nType the start phrase. (to exit 'x')\r\n------------------------------------------")
    
    start_phrase = input()

print('Done.')
