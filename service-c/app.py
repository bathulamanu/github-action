from flask import Flask

app = Flask(__name__)

@app.route('/')
@app.route('/service-c')   # ✅ ADD THIS
def home():
    return "Hello from rug Service C"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
