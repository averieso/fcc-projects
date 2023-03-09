#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~ MY SALON ~~~~"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "\nWelcome to My Salon, how may I help you?\n" 
  fi

  SERVICES=$($PSQL "select * from services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo -e "$SERVICE_ID) $SERVICE_NAME" 
  done
  read SERVICE_ID_SELECTED
  # check if the input is valid
  SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
  SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/ //')
  # if service number not valid
  if [[ -z $SERVICE_NAME ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # customer info
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    # if new customer
    if [[ -z $CUSTOMER_NAME ]]
    then 
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      # insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers (name, phone) values('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi
    CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/ //')
    echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
    read SERVICE_TIME
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    INSERT_APPOINTMENT_RESULT=$($PSQL "insert into appointments (customer_id, service_id, time) values('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED.\n"
  fi
}


MAIN_MENU
