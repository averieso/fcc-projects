#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=postgres --tuples-only -c"

echo "Enter your username:"
read READ_USERNAME

USERNAME=$($PSQL "select username from users where username = '$READ_USERNAME'")

if [[ -z "$USERNAME" ]]; then
  echo "Welcome, $READ_USERNAME! It looks like this is your first time here."
  insert_new_user=$($PSQL "insert into users(username) values ('$READ_USERNAME')")
else
  GAMES_PLAYED=$($PSQL "select games_played from users where username = '$READ_USERNAME'")
  BEST_GAME=$($PSQL "select best_game from users where username = '$READ_USERNAME'")
  echo "Welcome back,$USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

USER_ID=$($PSQL "select user_id from users where username = '$READ_USERNAME'")
if [[ $BEST_GAME -eq -100 ]] || [[ -z $BEST_GAME ]]; then
  BEST_GAME=10000
fi

ANS=$((($RANDOM % 1000) + 1))
NUM_GUESS=1

echo "Guess the secret number between 1 and 1000:"
read GUESS
update_num_games=$($PSQL "update users set games_played = games_played + 1 where user_id = '$USER_ID'")
while [ "$GUESS" != "$ANS" ]
do
  if ! [[ $GUESS =~ ^[0-9]+$ ]] ; then
    echo "That is not an integer, guess again:"
    read GUESS
  else
    if [ "$GUESS" -lt "$ANS" ]; then
      echo "It's higher than that, guess again:"
    elif [ "$GUESS" -gt "$ANS" ]; then
      echo "It's lower than that, guess again:"
    fi
    read GUESS
    NUM_GUESS=$((NUM_GUESS+1))
  fi
done

echo "You guessed it in $NUM_GUESS tries. The secret number was $ANS. Nice job!"

if [ "$NUM_GUESS" -lt "$BEST_GAME" ]; then
  q=$($PSQL "update users set best_game='$NUM_GUESS' where user_id='$USER_ID'")
fi
exit 0
