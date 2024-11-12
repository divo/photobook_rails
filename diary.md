# 12/11/24
Getting a lot of (relativly) new user signups. Not sure what's causing it. Trying to use google analytics to figure out how far they are getting. 
I'm being scanned by Russian bots.
Add rules to nginx to geo block Russia. This has not been added to the runbook. There is an RU.conf containding a "<CIDR> 1;" of all Russian IP blocks. This is loaded by the nginx config file (the file generated my ansible, although at the moment a deplyment will destroy these chanegs)
