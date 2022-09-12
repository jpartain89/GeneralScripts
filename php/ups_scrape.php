#!/usr/bin/php
<?php

$command = "apcaccess";
$args = "status";
$tagsArray = array(
"LOADPCT",
"BATTV",
"TIMELEFT",
"BCHARGE",
"LINEV",
"NUMXFERS"
);

//do system call

$call = $command." ".$args;
$output = shell_exec($call);

//parse output for tag and value

foreach ($tagsArray as $tag) {

preg_match("/".$tag."\s*:\s([\d|\.]+)/si", $output, $match);

//send measurement, tag and value to influx

sendDB($match[1], $tag);

}
//end system call

//send to influxdb

function sendDB($val, $tagname) {

$curl = "curl -i -XPOST 'http://10.0.100.41:8086/write?db=ups' --data-binary 'APC,host=jpserver.home.jpcdi.com ".$tagname."=".$val."'";
$execsr = exec($curl);

}

?>
