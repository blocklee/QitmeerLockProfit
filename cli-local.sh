#!/bin/bash

host=127.0.0.1
port=18131
user=qitmeer
pass=qitmeer123

./cli.sh -h "$host" -p "$port" --user "$user" --password "$pass" $@