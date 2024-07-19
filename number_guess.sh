#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Create the database and tables if they don't exist
#$PSQL "CREATE TABLE IF NOT EXISTS users (user_id SERIAL PRIMARY KEY, username VARCHAR(22) UNIQUE, games_played INT DEFAULT 0, best_game INT);"

# Function to get user informations
get_user_info() {
  USERNAME=$1
  USER_INFO=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username='$USERNAME';")
  echo "$USER_INFO"
}

# Function to insert new users
insert_new_user() {
  USERNAME=$1
  $PSQL "INSERT INTO users (username) VALUES ('$USERNAME');"
}

# Function to update user information
update_user_info() {
  USERNAME=$1
  GAMES_PLAYED=$2
  BEST_GAME=$3
  $PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE username='$USERNAME';" > /dev/null
}

# Function to prompt for username and handle user info
handle_user() {
  echo "Enter your username:"
  read USERNAME

  USER_INFO=$(get_user_info "$USERNAME")

  if [[ -z $USER_INFO ]]; then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    insert_new_user "$USERNAME"
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")
    GAMES_PLAYED=0
    BEST_GAME=1000
  else
    IFS='|' read -r USER_ID GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi
}

# Function to play the game
play_game() {
  SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
  NUMBER_OF_GUESSES=0

  echo "Guess the secret number between 1 and 1000:"
  
  while true; do
    read GUESS

    if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
      echo "That is not an integer, guess again:"
      continue
    fi

    ((NUMBER_OF_GUESSES++))

    if (( GUESS < SECRET_NUMBER )); then
      echo "It's higher than that, guess again:"
    elif (( GUESS > SECRET_NUMBER )); then
      echo "It's lower than that, guess again:"
    else
      echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
      break
    fi
  done

  ((GAMES_PLAYED++))

  if (( NUMBER_OF_GUESSES < BEST_GAME )); then
    BEST_GAME=$NUMBER_OF_GUESSES
  fi

  update_user_info "$USERNAME" $GAMES_PLAYED $BEST_GAME
}

# Main function
main() {
  handle_user
  play_game
}

main
