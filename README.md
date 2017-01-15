## Amazon Web Services Commandline Client ##
**********
Simple and lightweight ubuntu based Docker Image for Amazon web services command line tool (awscli)

### Usage ###
***********
Action  | Command
--------------- | -------------
**Pull**  | `docker pull satishweb/awscli`
**Run**  | `docker run --rm -e AWS_ACCESS_KEY_ID=<key> -e AWS_SECRET_ACCESS_KEY=<secret> -e AWS_DEFAULT_REGION=<region> -it satishweb/awscli <command> <options>`
**Alias** | `aws(){dParam='run --rm -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION -it satishweb/awscli'; [[ "$1" ]] && eval docker $dParam $@ && return; eval docker $dParam help}`
**With Creds** | `docker run -i -t --rm -v mycredentialsfile:/root/.aws/credentials:ro satishweb/awscli <command> <options>`

*Note: You can setup alias in ~/.bashrc or /etc/profile to make `aws` command available in each shell by default*

### Useful Commands ###
************
Action | Command
---------|-----------
aws version | `docker run --rm -it satishweb/awscli --version`
aws help |  `docker run --rm -it satishweb/awscli help`

*Note: If you run this image in AWS ECS then ensure you have atleast 40MB memory configured.*

### AWSCLI Configurations ###
*************
We can write awscli config file and run docker image with it (see Usage section).

#### Credentials Config Example: ####
>[default]
>aws_access_key_id=XXXXXXXXXXX
>aws_secret_access_key=xxxxxxxxxxxxxxxxxx
>region=us-east-1
>output=text



### AWSCLI Versions ###
************
TAG | AWSCLI Version | Docker Pull Command
--------------- | -------------|---------
**[latest](https://github.com/satishweb/docker-awscli/blob/master/Dockerfile)** | 1.11.36 |  `docker pull satishweb/awscli`
**[1.11.36](https://github.com/satishweb/docker-awscli/blob/1.11.36/Dockerfile)**| 1.11.36 |  `docker pull satishweb/awscli:1.11.36`

### Found Issues? ###
************
***Please help me resolve issues that you notice by reporting them *** [HERE](https://github.com/satishweb/docker-awscli/issues)

### References ###
************
Title | Reference
-------|-------------
AWS Client Help | <https://aws.amazon.com/cli/>
Ubuntu Docker Image | <https://hub.docker.com/_/ubuntu/>