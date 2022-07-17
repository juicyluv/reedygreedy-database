#!/bin/bash

INIT_FILE=patch/init.sql;

printf "\n-- THIS FILE IS AUTOGENERATED. DO NOT EDIT.\n" >> $INIT_FILE

cat patch/base.sql > $INIT_FILE

for schema in main core
do
  printf "\n------------------------------------------------------------------------------------------------------------------------\n" >> $INIT_FILE

  cat database/$schema/$schema.sql >> $INIT_FILE

  printf "\n------------------------------------------------------------------------------------------------------------------------" >> $INIT_FILE

  for table in database/$schema/tables/*
  do
    printf "\n\n" >> $INIT_FILE
    cat $table >> $INIT_FILE
    printf "\n------------------------------------------------------------------------------------------------------------------------" >> $INIT_FILE
  done
  printf "\n------------------------------------------------------------------------------------------------------------------------" >> $INIT_FILE

  for view in database/$schema/views/*
  do
    printf "\n\n" >> $INIT_FILE
    cat $view >> $INIT_FILE
    printf "\n------------------------------------------------------------------------------------------------------------------------" >> $INIT_FILE
  done
  printf "\n------------------------------------------------------------------------------------------------------------------------" >> $INIT_FILE

  for function in database/$schema/functions/*
  do
    printf "\n\n" >> $INIT_FILE
    cat $function >> $INIT_FILE
    printf "\n------------------------------------------------------------------------------------------------------------------------" >> $INIT_FILE
  done
  printf "\n------------------------------------------------------------------------------------------------------------------------" >> $INIT_FILE
done;
  printf "\n------------------------------------------------------------------------------------------------------------------------\n" >> $INIT_FILE

cat patch/feed.sql >> $INIT_FILE;