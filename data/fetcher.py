# Start with relevant imports
from __future__ import division
from flask import Flask,request,json,jsonify,abort
import uuid,json
from flask.ext.sqlalchemy import SQLAlchemy
from models import *

def object_to_data_dict(arg,desired_field):
	if (type(arg)==list):
		return map(lambda x:{'year':int(x.yearID),\
		 'value' : int((x.__dict__[desired_field]))},arg)
	else:
		return {'year':int(arg.yearID),\
		'value':int((arg.__dict__[desired_field]))}

def list_average(list1,list2):
	averaged = []
	for i in range(len(list1)):
		year = list1[i]['year']
		value1 = list1[i]['value']
		value2 = list2[i]['value']
		averaged.append({"year":year,'value':round((value1/value2),3)})
	return averaged

def do_stats(player_stats,dict_):
	stats = ['H','doubles','triples','HR','RBI','SB','R','AB']
	for stat in stats:
		dict_[stat] = object_to_data_dict(player_stats,stat)
	dict_['BA'] = list_average(dict_['H'],dict_['AB'])


def filter_list_by_year(list_,year):
	return filter(lambda x:(x.yearID==year),list_)

def query_player_data(playerID,f):
	player_master = Master.query.filter_by(playerID=playerID).first()
	player_salary = Salaries.query.filter_by(playerID=playerID).all()
	player_appearances = Appearances.query.filter_by(playerID=playerID).all()
	player_awards = AwardsPlayers.query.filter_by(playerID=playerID).all()
	player_awards_votes = AwardsSharePlayers.query.filter_by(playerID=playerID).all()
	if (player_appearances[0].G_p>10):
		batter = False
		player_stats = Pitching.query.filter_by(playerID=playerID).all()
		player_post = PitchingPost.query.filter_by(playerID=playerID).all()
	else:
		batter = True
		player_stats = Batting.query.filter_by(playerID=playerID).all()
		player_post = BattingPost.query.filter_by(playerID=playerID).all()
	json_return = {}
	json_return['firstName'] = player_master.nameFirst
	json_return['lastName'] = player_master.nameLast
	json_return['birthday'] = ("%d/%d/%d")%\
		(player_master.birthMonth,player_master.birthDay,player_master.birthYear)
	json_return['handedness'] = ("Bats: %s, Throws: %s")%(player_master.bats,player_master.throws)
	json_return['hometown'] = ("%s, %s, %s")%\
		(player_master.birthCity,player_master.birthState,player_master.birthCountry)
	if (f==None):
		do_stats(player_stats,json_return)
	elif (type(f)==int):
		player_stats = filter_list_by_year(player_stats,f)
		do_stats(player_stats,json_return)
	else:
		relevant_stats = []
		for year in range(f["start"],f["end"]+1):
			relevant_stats.append(filter_list_by_year(player_stats,year)[0])
		do_stats(relevant_stats,json_return)
	return json_return

		






hi = query_player_data('rodrial01',{"start":2008,"end":2010})
print hi

if __name__ == '__main__':
	app.run(debug=True)


