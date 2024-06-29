from flask import Flask, jsonify
from flask_cors import CORS

app = Flask(__name__)

app = Flask(__name__)
CORS(app)

@app.route('/', methods=['GET'])
def get_sorted_data():
    # with open('app_versions.json') as f:
        # data = json.load(f)
    data = [
        {
            "version": "1.0.0",
            "change_log": "First release",
            "description": "First release description",
            "download_link": "Lorem ipsum",
            "publish_year": 2024,
            "publish_month": 6,
            "publish_day": 29,
            "publish_date": "2024-6-29",
            "file_size": "50.4",
            "file_name": "app-arm64-v8a-release-v1.0.0.apk"
        },
    ]
        

    # Sort the data by the newest date first
    data.sort(key=lambda x: x['publish_date'], reverse=True)

    return jsonify(data)

if __name__ == '__main__':
    app.run(debug=True)