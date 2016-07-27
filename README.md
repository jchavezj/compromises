# compromises
Script to search for possible compromises on Linux Servers.

Function
-------

Function name | Description 
--------------| -----------
write_header | Used to create the Head details for the functions
xpscan | This functions searches for a pattern in php files
wp | This compares the version of Wordpress installed to the latest availabe Wordpress version
process | Search the logs for injections using a pattern match
pentest | This will run unix-privesc-check which will search for security issues on the server
