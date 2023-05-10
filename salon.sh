#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# Salon Appointment Scheduler

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

SERVICES_DISPLAY() {
  echo "$SERVICES" | while read ID BAR NAME
  do
    echo "$ID) $NAME"
  done
  read SERVICE_ID_SELECTED


}

INVALID_SERVICES() {
  
  # if not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # select again
    echo -e "\nI could not find that service. What would you like today?"
    SERVICES_DISPLAY 
  fi
  
  SERVICE_INFO=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  # if not in service
  if [[ -z $SERVICE_INFO ]]
  then 
    # select again
    echo -e "\nI could not find that service. What would you like today?"
    SERVICES_DISPLAY 
  fi
}



BOOK_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # get services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  SERVICES_DISPLAY
  INVALID_SERVICES
  
  # get customer info
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # if customer doesn't exist in the database
  if [[ -z $CUSTOMER_NAME ]]
  then
    # get new customer name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    # insert new customer 
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi

  # get customer id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # get time for reservation
  SERVICE_INFO=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  SERVICE_INFO_FORMATTED=$(echo $SERVICE_INFO | sed 's/ //')
  CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/ //')
  echo -e "\nWhat time would you like your $SERVICE_INFO_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
  read SERVICE_TIME
    
  # create an appointment
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
    
  if [[ $INSERT_APPOINTMENT_RESULT="INSERT 0 1" ]]
  then
    # output the appointment message
    echo -e "\nI have put you down for a $SERVICE_INFO_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
  fi

}

BOOK_MENU
