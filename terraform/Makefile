.PHONY: all plan apply destroy

all: init plan apply

init:
	terragrunt init --terragrunt-non-interactive 

plan:
	terragrunt plan -var "aws_access_key=${AWS_ACCESS_KEY_ID}" -var "aws_secret_key=${AWS_SECRET_ACCESS_KEY}" 

apply:
	terragrunt apply -var "aws_access_key=${AWS_ACCESS_KEY_ID}" -var "aws_secret_key=${AWS_SECRET_ACCESS_KEY}" 

destroy:
	terragrunt destroy -var "aws_access_key=${AWS_ACCESS_KEY_ID}" -var "aws_secret_key=${AWS_SECRET_ACCESS_KEY}" 
