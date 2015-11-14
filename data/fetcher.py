# Start with relevant imports
from flask import Flask,request,json,jsonify,abort
import uuid,json
from flask.ext.sqlalchemy import SQLAlchemy
from models import *

def query_player_data(playerID,f):
	player_master = Master.query.filter_by(playerID=playerID).first()
	player_appearances = Appearances.query.filter_by(playerID=playerID).first()
	player_salary = Salaries.query.filter_by(playerID=playerID).first()
	if (player_appearances.G_p>10):
		batter = False
		player_stats = Pitching.query.filter_by(playerID=playerID).first()
		player_post = PitchingPost.query.filter_by(playerID=playerID).first()
	else:
		batter = True
		player_stats = Batting.query.filter_by(playerID=playerID).first()
		player_post = BattingPost.query.filter_by(playerID=playerID).first()
	json_return = {}
	json_return['firstName'] = player_master.nameFirst
	json_return['lastName'] = player_master.nameLast
	json_return['birthday'] = ("%d/%d/%d")%\
		(player_master.birthMonth,player_master.birthDay,player_master.birthYear)
	json_return['handedness'] = ("Bats: %s, Throws: %s")%(player_master.bats,player_master.throws)
	json_return['hometown'] = ("%s, %s, %s")%\
		(player_master.birthCity,player_master.birthState,player_master.birthCountry)
	json_return['salary'] = player_salary.salary

	return json_return['salary']



print(query_player_data('abbeych01',None))

if __name__ == '__main__':
	app.run(debug=True)


