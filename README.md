This challenge requires that the chef script be used to configure locations and permissions.

Solution:
In the seach bar, type "author=sudo -u timmy cat /home/corporate_secrets/flag.txt"

The author= is found by studying the source code provided. Looking through the source code, it can be determined that the search box has a special handler for author= and that the handler passes the string to the shell.

Browsing the system using the backdoor, they can find the directory /home/corporate_secrets, which should be the obvious tartet.

To learn the contents of the directory, users must use sudo to perfrom an ls.

A simple sudo command does not grant access to the flag however. Performin a sudo ls -l /home/corporate_secrets reveals the directory can only be read by the fread group. Checking the /etc/group file, the user learns timmy is in that group.

Trying to 'cat' the file as timmy, ie, sudo -u timmy cat /home/corporate_secrets/flag.txt reveals the flag MCA-40B3E9F8.
