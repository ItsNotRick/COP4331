from flask import Flask, request, jsonify, url_for, abort
from flask_sqlalchemy import SQLAlchemy

from passlib.apps import custom_app_context as pwd_context
import json

# // "SETUP_COMMAND" : "CREATE TABLE Users(id INT AUTO_INCREMENT PRIMARY username VARCHAR(80) NOT NULL, pwd_hash VARCHAR(80) NOT NULL, UNIQUE KEY unique_username (username));"         

app = Flask(__name__)

with open('config.json', 'r') as f:
    config = json.load(f)["DEFAULT"]


engine_uri = "mysql://%s:%s@%s/%s" % (config["USERNAME"], config["PASSWORD"], config["HOST"], config["DBNAME"])
# engine = create_engine(engine_uri, pool_recycle=3600)
app.config['SQLALCHEMY_DATABASE_URI'] = engine_uri
db = SQLAlchemy(app)

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    pwd_hash = db.Column(db.String(120), nullable=False)

    def hash_password(self, password):
        self.pwd_hash = pwd_context.encrypt(password)
    def verify_password(self, password):
        return pwd_context.verify(password, self.pwd_hash)

    def __init__(self, username, password):
        self.username = username
        self.hash_password(password)

    def __repr__(self):
        return '<User %r>' % self.username



@app.route('/')
def hello_world():
	return 'Hello!'

@app.route('/api/register', methods=['GET','POST'])
def register():
    user = request.json.get('username')
    pwd = request.json.get('password')
    if user is None or pwd is None:
        abort(400) 
    if User.query.filter_by(username = user).first() is not None:
        abort(400)
    user = User(username = user, password = pwd)
    db.session.add(user)
    db.session.commit()
    return "User Accepted"

if __name__ == '__main__':
    app.run(debug=True)