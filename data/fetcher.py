# Start with relevant imports
from __future__ import division
from collections import Counter
from flask import Flask,request,json,jsonify,abort,Response
import uuid,json
from flask.ext.sqlalchemy import SQLAlchemy
from models import *
from flask.ext.cors import CORS

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

def full_name(playerID):
	return Master.query.filter_by(playerID=playerID).\
	first().nameFirst+" "+Master.query.filter_by(playerID=playerID).\
	first().nameLast

def do_stats(player_stats,dict_):
	stats = ['H','doubles','triples','HR','RBI','SB','R','AB']
	for stat in stats:
			dict_[stat] = object_to_data_dict(player_stats,stat)
	dict_['BA'] = list_average(dict_['H'],dict_['AB'])

def furthest_success(team_year):
	if (team_year.WCWin=='Y' or team_year.divWin=='Y'):
		won_division = (team_year.divWin=='Y')
		if (team_year.LgWin=='Y'):
			if (team_year.WSWin=='Y'):
				return {"year":int(team_year.yearID),"value":'WWS'}
			return {"year":int(team_year.yearID),"value":'LWS'}
		if won_division: return {"year":int(team_year.yearID),"value":'WDV'}
		return {"year":int(team_year.yearID),"value":'WWC'}
	return {"year":int(team_year.yearID),"value":'NPO'}

def team_leaders(teamID,f):
	if (f == None):
		return {'value':'no team leaders'}
	if (type(f)==int):	
		firstyear = f
		lastyear = f
	else:
		firstyear = f["start"]
		lastyear = f["end"]
	list_of_players = Batting.query.filter_by(teamID=teamID).all()
	list_of_players = filter(lambda x: (x.yearID>=firstyear and x.yearID<=lastyear),list_of_players)
	for guy in list_of_players:
		print guy.playerID
		try:
			guy = query_player_data(guy.playerID,f)
		except:
			pass

	print list_of_players

def filter_list_by_year(list_,year):
	return filter(lambda x:(x.yearID==year),list_)

def query_player_data(playerID,f):
	player_master = Master.query.filter_by(playerID=playerID).first()
	player_salary = Salaries.query.filter_by(playerID=playerID).all()
	player_appearances = Appearances.query.filter_by(playerID=playerID).all()
	player_awards = AwardsPlayers.query.filter_by(playerID=playerID).all()
	player_awards_votes = AwardsSharePlayers.query.filter_by(playerID=playerID).all()
	if (len(player_appearances)!=0):
		if (player_appearances[0].G_p>10):
			batter = False
			player_stats = Pitching.query.filter_by(playerID=playerID).all()
			player_post = PitchingPost.query.filter_by(playerID=playerID).all()
		else:
			batter = True
			player_stats = Batting.query.filter_by(playerID=playerID).all()
			player_post = BattingPost.query.filter_by(playerID=playerID).all()
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
	resp = Response(response=json.dumps(json_return),
		status = 200, mimetype="application/json")
	return resp

		
def query_team_data(teamID,f):
	team_master = Teams.query.filter_by(teamID=teamID).all()
	managers = Managers.query.filter_by(teamID=teamID).all() 
	json_return = {}
	json_return['stadium'] = team_master[-1].park
	if (type(f)==int):
		team_master = filter_list_by_year(team_master,f)
		managers = filter_list_by_year(managers,f)
	elif (f==None):
		pass
	else:
		relevant_stats = []
		relevant_managers = []
		for year in range(f["start"],f["end"]+1):
			relevant_stats.append(filter_list_by_year(team_master,year)[0])
			relevant_managers.append(filter_list_by_year(managers,year)[0])
		team_master = relevant_stats
		managers = relevant_managers
	json_return['furthest_success'] = map(furthest_success,team_master)
	fields = ['attendance','W','L','Rank']
	for field in fields:
		json_return[field] = object_to_data_dict(team_master,field)
	json_return["manager"] = Counter(map(lambda x: x.playerID,managers))[0]
	json_return["manager"] = full_name(json_return["manager"])
	resp = Response(response=json.dumps(json_return),
		status = 200, mimetype="application/json", headers={'Access-Control-Allow-Origin': '*'})
	return resp

@app.route('/v1/data', methods=['POST'])
def handle_data():
	data = json.loads(request.data)
	if (data["entity"] == "team"):
		if "filter" in data:
			if (data["filter"]==None): 
				return query_team_data(data["id"],None)
			return query_team_data(data["id"],data["filter"])
		else:
			return query_team_data(data["id"],None)
	if (data["entity"] == "player"):
		if "filter" in data:
			if (data["filter"]==None): 
				return query_player_data(data["id"],None)
			return query_player_data(data["id"],data["filter"])
		else:
			return query_player_data(data["id"],None)


	return 'bad query'



if __name__ == '__main__':
	CORS(app)
	app.run(debug=True)


