#!/bin/bash

# You'll need httpie to run this

http --body --json GET http://localhost:3000/json/hosts
http --body --json GET http://localhost:3000/json/services/localhost
http --body --json GET http://localhost:3000/json/state/localhost/Current%20Users