# Start with relevant imports
from flask import Flask,request,json,jsonify,abort
import uuid,json
from flask.ext.sqlalchemy import SQLAlchemy
# set up flask app
app = Flask(__name__)
# link to local sqlite database
app.config['SQLALCHEMY_DATABASE_URI'] = \
'mysql://mlb@localhost'
# initialize Database
db = SQLAlchemy(app)