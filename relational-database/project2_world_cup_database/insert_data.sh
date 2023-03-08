#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "truncate table teams, games")

cat games.csv | while  IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # insert teams
  if [[ $WINNER != winner ]]
  then
    # get team_id
    WINNER_ID=$($PSQL "select team_id from teams where name='$WINNER'")
    # if not found
    if [[ -z $WINNER_ID ]]
    then
      INSERT_WINNER=$($PSQL "INSERT INTO teams (name) VALUES('$WINNER')")
      echo Inserted into teams, $WINNER
    fi
  fi
  if [[ $OPPONENT != opponent ]]
  then
    # get team_id
    OPPONENT_ID=$($PSQL "select team_id from teams where name='$OPPONENT'")
    # if not found
    if [[ -z $OPPONENT_ID ]]
    then
      INSERT_OPPONENT=$($PSQL "INSERT INTO teams (name) VALUES('$OPPONENT')")
      echo Inserted into teams, $OPPONENT
    fi
  fi

  # insert to games
  WINNER_ID=$($PSQL "select team_id from teams where name='$WINNER'")
  OPPONENT_ID=$($PSQL "select team_id from teams where name='$OPPONENT'")
  INSERT_OTHERS=$($PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES('$YEAR', '$ROUND', '$WINNER_ID', '$OPPONENT_ID', '$WINNER_GOALS', '$OPPONENT_GOALS')")
  echo Inserted into games, $YEAR $ROUND $WINNER $OPPONENT $WINNER_GOALS $OPPONENT_GOALS
done
