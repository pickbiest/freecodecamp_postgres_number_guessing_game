#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t -c"

echo -e "\n~~~ Number guessing game ~~~\n"
echo "Enter your username:"
read USER_NAME

DB_USER=$($PSQL "select * from users where username = '$USER_NAME';")
if [[ $DB_USER ]]
then
  read USER_ID BAR USER_NAME BAR GAMES_PLAYED BAR BEST_GAME < <(echo "$DB_USER")
  echo "Welcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  echo "Welcome, $USER_NAME! It looks like this is your first time here."
fi

RANDOM_NUMBER=$((1 + RANDOM % 1000))
#echo $RANDOM_NUMBER

INPUT_TEXT="Guess the secret number between 1 and 1000:"
NR_OF_GUESSES=0
while [[ ! $GUESS = $RANDOM_NUMBER ]]
do
  echo $INPUT_TEXT;
  read GUESS
  ((NR_OF_GUESSES++))

  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -lt $RANDOM_NUMBER ]]
  then
    INPUT_TEXT="It's lower than that, guess again:"
  elif [[ $GUESS -gt $RANDOM_NUMBER ]]
  then
    INPUT_TEXT="It's higher than that, guess again:"
  fi
done

if [[ -z $DB_USER ]]
then
  INSERT=$($PSQL "insert into users(username, best_game) values ('$USER_NAME', $NR_OF_GUESSES);")
else
  INSERT=$($PSQL "update users set games_played = games_played + 1 where username = '$USER_NAME';")
  if [[ $NR_OF_GUESSES -lt $BEST_GAME ]]
  then
    INSERT=$($PSQL "update users set best_game = $NR_OF_GUESSES where username = '$USER_NAME';")
  fi
fi

echo "You guessed it in $NR_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
