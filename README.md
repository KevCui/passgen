passgen
=======

A password generator creates password based on a string and a file.

## How it works

This script requires a string and a file as input. The script will get SHA checksum of the file and use it as salt. Then the password string will be created from the hash of the concatenated string and salt.

If you want to generate same password every time using same string, it's important to NOT change the file content (SHA512 checksum).

## How to use

```
Usage:
  ./pg.sh [-s|-c|-x] [<length>]

Options:
  length          Optional, must be an integer inside range (0, 105]
                  Default length is 29
  -s              Optional, show result in terminal only
                  Default not show result, copy result to clipboard
  -c              Optional, make first letter uppercase
  -x              Optional, output hex chars
                  Default base64 chars
  -h | --help     Show usage message
```

1. Pick any file as base, can be a doc, a binary, an SSH key... ideally any file which is read-only. Set global variable `PG_FILE` in terminal:

```
export PG_FILE="<path_to_file>"
```

2. Run script to generate password

```
~$ ./pg.sh
```

3. See prompt "Enter a string", enter any string. In order to get different passwords, it's better to pick something different for each site/app, like domain name of website, app name, user name...

4. Ctrl-v/paste password to where you want

### Example:

- Generate a password with 20 chars:

```
~$ ./pg.sh 20
```

- Generate a password with 1 char uppercase:

```
~$ ./pg.sh -c
```
- Generate a password with only hex chars:

```
~$ ./pg.sh -x
```

- Show generated password as output in terminal:

```
~$ ./pg.sh -s
wepk0$TOseO$Gzpoj$I9a0N$EYrLv
```

## Run tests

```
~$ bats test/pg.bats
```
