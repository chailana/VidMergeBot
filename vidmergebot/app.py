from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "Hello, Koyeb!"

if __name__ == "__main__":
    # Ensure the app listens on port 8000
    app.run(host="0.0.0.0", port=8000)
