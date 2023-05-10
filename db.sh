#!/bin/bash

mysql -uroot -p GameDB < doc/db_database.sql
echo "databses create success"
mysql -uroot -p GameDB < doc/db_table.sql
echo "table create success"