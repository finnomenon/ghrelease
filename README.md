# ghrelease
A simple ruby script to upload releases to github using the HTTP API.

Usage
---
Set enviroment variables OWNER and OTOKEN to your Github username and the application oauth token respectively, or just set them in the program call itself, as below.

```bash
OWNER="username" OTOKEN="verylongoathtokenhere" ruby ghrelease.rb --artifact reponame --version releasename file1 subdir/file2 subdir2/*
```
If the release does not exist, it will be created. The specified files will then be uploaded one by one.
