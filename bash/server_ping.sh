#!/bin/bash

# Script to run a ping test and subsequently shoot a text.

if ping -c 10 8.8.8.8 > /dev/null; then \
    curl -X POST http://textbelt.com/text \
    -d number=2149239252 \
    -d "message=Mark's Server is Down.... This is to annoy you!"
fi
