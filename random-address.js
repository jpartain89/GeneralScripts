#!/usr/bin/env node

var streetName = ['Main St.', 'Columbia', 'Munger Dr.', 'Elm Street', 'San Jacinto Blvd.', 'Lucas Dr.']

var cityName = ['San Francisco', 'New York', 'Houston', 'Texarkana', 'Austin', 'Chicago', 'San Antonio']

var stateName = ['Arizona', 'New York', 'Illinois', 'California', 'Texas']

var zipCode = Math.floor(10000 + Math.random() * 90000);
var streetNumber = Math.floor(1000 + Math.random() * 9000);

function getRandom(input) {
    return input[Math.floor((Math.random() * input.length))];
}

function createAdress() {
    return `${streetNumber} ${getRandom(streetName)} 
${getRandom(cityName)}, ${getRandom(stateName)} ${zipCode}`;
}

var address = createAdress();
console.log(address);
