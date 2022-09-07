#!/bin/bash
# FCC Challenge Relational Database - Salon Appointment

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c "

echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  # Fetch and display menu
  AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services")
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done

  # Get service_id from user
  read SERVICE_ID_SELECTED

  # Validation if a valid input: Number only
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ || -z $SERVICE_ID_SELECTED ]]
  then
    # Move user back to MAIN_MENU with message
    MAIN_MENU "Please enter a number. What would you like today?"

  else
    # Fetch Service Name
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

    # if service not found
    if [[ -z $SERVICE_NAME ]]
    then
      # Move user back to MAIN_MENU with message
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      # get INPUT customers phone
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      # fetch cust name with phone
      read CUSTOMER_ID BAR CUSTOMER_NAME <<< $($PSQL "SELECT customer_id, name FROM customers WHERE phone ILIKE '$CUSTOMER_PHONE'")

      # if name not found
      if [[ -z $CUSTOMER_NAME ]]
      then
        # get cust name
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME

        # add cust name and phone db
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

        # fetch customer_id
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME'")
      fi
      
      # get time from cust with name
      echo -e "\nWhat time would you like your$SERVICE_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME

      # add to appointment db
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")

      # final message
      echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi

}

MAIN_MENU