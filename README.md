dropbox-shell
=============

A BASH script to run scripts/programs on a remote machine via Dropbox.

First you have to set up a folder within your Dropbox with the following
structure:   
Dropbox/remote/   
Dropbox/remote/old/   
Dropbox/remote/output/   
Dropbox/remote/commands/   
Dropbox/remote/toprint/   
Dropbox/remote/printed/

Optionally, remote can be named remote_{something} if you want to do this on
multiple machines so that you may distinguish them.

Place any executable files (scripts or compiled programs) into the commands
folder.

Then run the following command to execute scripts on your machine:   
dropbox_shell.sh   
or dropbox_shell.sh {something}

All files in the commands folder will be executed. Output will be written to a
log file in output, and the file will be moved to the old folder. Additionally,
printable files in toprint will be printed, and moved to the printed folder.

If no files are found in commands or toprint, the program does nothing.

Ideally, this should be added to a cronjob. My cronjob for this looks like this:   
*/3 * * * *     bash /path/to/dropbox_shell.sh   
This runs it every three minutes.

If a file in the commands folder is named "at-some time string", instead of
executing it right away, it's assumed to be a bash script to be run using the
"at" command, and "some time string" is the time to execute it. E.g., creating a
script in the folder called "at-now + 20 minutes" will cause that file to be run
twenty minutes from the time dropbox_shell is run.
