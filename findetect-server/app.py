from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
    return '<html> <head>FinDetect<title>FinDetect</title> </head> <body><form action="upload" method="post" id="upload-form">    <input type="file" name="imagefile" id="imagefile"/>    <input type="submit" />  </form></body></html>'




@app.route('/upload', methods=['POST'])
def upload():
    try:
        imagefile = flask.request.files.get('imagefile', '')
        print('Succesfull upload Yay!');
    except Exception as err:
	print('Upload Failed ')
