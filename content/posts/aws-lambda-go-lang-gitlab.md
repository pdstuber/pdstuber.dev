+++ 
draft = true
date = 2019-04-28T21:16:00+02:00
title = "Build and deploy a golang AWS lambda function with AWS SAM and Gitlab CI"
description = ""
slug = "" 
tags = ["golang", "aws lambda", "sam", "gitlab-ci"]
categories = []
externalLink = ""
series = []
+++

## Prerequisites

- AWS account
- Gitlab account
- AWS CLI user with access key id and secret

## Skeleton project

You can fork / copy this sample project:

```bash
git clone https://gitlab.com/pdstuber/go-aws-lambda-skeleton.git
```
__Project structure__

* _.gitlab-ci.yml_: Describes the gitlab CI/CD pipeline we're going to use.
* _deploy/_: Contains the aws config json files for the resources we need to create
* _.gitignore_: We want to ignore the go binary
* main.go: The sample lambda function code

## AWS Console

Logon to AWS console, go to IAM, create a new policy and paste the following json:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "GitlabCI",
      "Effect": "Allow",
      "Action": [
        "lambda:CreateFunction",
        "iam:GetRole",
        "lambda:GetFunction",
        "iam:CreateRole",
        "iam:DeleteRole",
        "s3:CreateBucket",
        "iam:AttachRolePolicy",
        "cloudformation:CreateChangeSet",
        "cloudformation:GetTemplateSummary",
        "cloudformation:DescribeStacks",
        "s3:PutObject",
        "s3:GetObject",
        "iam:PassRole",
        "iam:DetachRolePolicy",
        "cloudformation:DescribeStackEvents",
        "cloudformation:DescribeChangeSet",
        "cloudformation:ExecuteChangeSet"
      ],
      "Resource": "*"
    }
  ]
}
```

__You need to assign this policy to your CLI user.__

## Gitlab 
### config

Go to __https://gitlab.com/${user}/${repo}/settings/ci_cd__. 

Replace ${user} with your gitlab username and ${repo} with the repo you created.

Expand __Environment variables__. 

Set the environment variables __AWS_ACCESS_KEY_ID__ and __AWS_SECRET_ACCESS_KEY__ to your access key id and secret.

### Pipeline
The pipeline is described in the file __.gitlab-ci.yml__.

Automated steps:

* codeQuality: Execute unit tests, linting, check source code formatting
* build: Run GO compiler and create zip archive
* deploy: Deploy on AWS via AWS SAM command line tool. Only run on master branch

Manual steps:

* createS3Bucket: Run this once to create the S3 bucket that is used to upload the zipped lambda function code by SAM


