# JSS-API-Wipe

### Introduction

This allows you to wipe "most" of the config from a JSS server via it's API

### Attribution

Big thanks to Jeffrey Compton for the API work he did with this:
https://github.com/igeekjsc/JSSAPIScripts/blob/master/jssMigrationUtility.bash

I have merely restructured a lot of his code to suit my own needs.

### Getting started

1. Run the script.
2. Follow the prompts.
3. There is no step 3!

You'll be asked for jss url, username and password with appropriate rights and an instance name if it's a multi-context install.

It'll then ask if you're very sure.

Then it'll proceed to wipe just about everything that can be wiped via the API (on v9.90) leaving you with a mostly blank JSS.
Some existing config will remain like DEP config, as that isn't in the API.