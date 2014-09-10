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

Optionally, the directory path can be specified as the initial argument, if a
folder other than `Dropbox/remote` is desired.

Previous versions allowed you to specify a separate directory in the form of
`Dropbox/remote_{something}` with `{something}` as the initial argument. I have
preserved this, however this behavior is deprecated, and may be removed in
future versions.

Place any executable files (scripts or compiled programs) into the commands
folder.

Then run the following command to execute scripts on your machine:   
`dropbox_shell.sh`   
or `dropbox_shell.sh {path}`

All files in the commands folder will be executed. Output will be written to a
log file in output, and the file will be moved to the old folder. Additionally,
printable files in toprint will be printed, and moved to the printed folder.

Certain special files (Java .jar, etc.) may be placed in the folder, and they
will be executed by their respective interpreters/virtual machines.

Currently supported special files are:

* `.class`: run as `java {classname}`
* `.jar`: run as `java -jar {file}`
* `.n`: run as `neko {file}`

Additional special files can be supported by adding BASH functions to the
script. The functions should be named like `run_${mimetype}_${extension}` where
mimetype is the mime-type of the file (as determined by `file -bi $file`), with
`/` being replaced with `_`, and all other non-alphabetic characters being
removed. So, if the mime-type is `application/octet-stream`, and the file
extension is `.foobar`, then the function definition would look something like
this:

    function run_application_octetstream_foobar()
	{
	    run_foobar "$1"
    }

The file to be executed is passed as the sole argument to the function.

Feel free to send me your additional functions, and I may add them to the
program.

Other files will be made executable, and executed directly, so be sure to
include a shebang in scripts.

If no files are found in commands or toprint, the program does nothing.

Ideally, this should be added to a cronjob. My cronjob for this looks like this:   
`*/3 * * * *     bash /path/to/dropbox_shell.sh`   
This runs it every three minutes.

If a file in the commands folder is named "at-some time string", instead of
executing it right away, it's assumed to be a bash script to be run using the
"at" command, and "some time string" is the time to execute it. E.g., creating a
script in the folder called "at-now + 20 minutes" will cause that file to be run
twenty minutes from the time dropbox_shell is run. This form should only be used
for shell scripts.
