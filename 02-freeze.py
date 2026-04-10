from app import app
import os

print("Freezing the Flask application into a static index.html...")

with app.app_context():
    # Make a test request to the root endpoint
    client = app.test_client()
    response = client.get('/')
    
    if response.status_code == 200:
        html_content = response.data.decode('utf-8')
        
        output_file = 'index.html'
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(html_content)
            
        print(f"Successfully generated {output_file} at the root of the project!")
        print("You can now commit this file and push to GitHub pages.")
    else:
        print(f"Failed to generate site. Status code: {response.status_code}")
