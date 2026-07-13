
# Task1 : : Setup AWS CLI Environment


Install aws using https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
using the curl with unzip and then the aws cli was install at /usr/local/bin/aws




I noticed that we have two way to login first using aws configure and  aws login. But the aws login is prefered because it is more secure and it is the recommended way to login. I used aws configure because I wasn't able to login using the aws login I was getting 400 as the SSO was not configure q

```shell
aws configure --profile sostene.amalitech
```

if 
after I run the command
```shell
aws sts get-caller-identity --profile sostene.amalitech
``` 
if you don't want to pass the --profile you also export the profile using the following command

```shell
export AWS_PROFILE=sostene.amalitech
```
and the following were the results
![Result after running the aws sts get-caller-identity command](./screenshots/sts-identity.jpg)
then I run the command 


```
after I run the command
```shell
aws configure list
``` 
The result were as the following
![Result after running the aws configure list command](./screenshots/configure-list.jpg)
# Task 2:
