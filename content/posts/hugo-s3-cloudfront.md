+++ 
draft = false
date = 2019-03-28T22:07:17+01:00
title = "Deploy a hugo blog website on AWS S3 and Cloudfront with Gitlab CI"
tags = ["hugo", "cloudfront", "s3"]
+++

## Prerequisites

- AWS account
- a domain
- a TLS certificate, e.g. from letsencrypt, imported in AWS certificate manager region us-east-1
- Gitlab account

## Create Access Key

### Create Policy for Gitlab CI

Logon to AWS console, go to IAM, create a new policy and paste the following json:

Replace __${domain}__ by the domain you use (e.g. __blog.johndoe.io__).

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "gitlabCI0",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::${domain}/*"
    },
    {
      "Sid": "gitlabCI1",
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:PutBucketWebsite",
        "s3:PutBucketPolicy",
        "s3:CreateBucket"
      ],
      "Resource": "arn:aws:s3:::${domain}"
    },
    {
      "Sid": "gitlabCI2",
      "Effect": "Allow",
      "Action": [
        "cloudfront:CreateInvalidation",
        "cloudfront:GetInvalidation",
        "cloudfront:ListInvalidations",
        "cloudfront:CreateDistribution"
      ],
      "Resource": "*"
    }
  ]
}
```

### Create user and access key
Again go to IAM, create a new user, hit the checkbox "Programmatic access" at access type.

On the next page choose "Attach existing policies directly" and specify the policy you created before. 
The other settings can be left with the defaults.

Note down the __Access key ID__ and __Secret access key__. You'll need them soon.

## Blog

You can fork this project as a basis:

https://gitlab.com/pdstuber/hugo-gitlab-ci-cloudfront-s3

### Project structure

* _.gitlab-ci.yml_: Describes the gitlab CI/CD pipeline we're going to use.
* _deploy/_: Contains the aws config json files for the resources we need to create
* _.gitignore_: The hugo CLI tool generates the static website in the folder "public/". We don't want to check that in so we added it to ignored

### Install hugo
https://gohugo.io/getting-started/installing

### Create your blog

Choose a theme from here: https://themes.gohugo.io/

In this example we use "ananke".

```bash
export domain="blog.johndoe.io"
hugo new site ${domain}
cd ${domain}
git init
# This will depend on your theme
git submodule add https://github.com/budparr/gohugo-theme-ananke.git themes/ananke
```

Replace __${domain}__ by your domain name. Adapt the submodule add for your theme.

You can create your first blog post with

```bash
hugo new posts/some-interesting-article.md
```

For further info about hugo you can checkout

https://gohugo.io/getting-started/

## Gitlab

### config

Go to `https://gitlab.com/${user}/${repo}/settings/ci_cd`. 

Replace __${user}__ with your gitlab username and __${repo}__ with the repo you created for your blog.

Expand __Environment variables__. 

Use the keys __AWS_ACCESS_KEY_ID__ and __AWS_SECRET_ACCESS_KEY__ and the values you noted down earlier

### Pipeline
The pipeline is described in the file __.gitlab-ci.yml__.

The build has four steps, two of which are automatically triggered on push to master branch:

__build:__ Use the hugo cli to generate a static website from your markdown files

__createCloudFrontDistribution:__
Manual step to create your cloudfront distribution.

__createS3Bucket:__
Manual step to create the bucket which will hold your website

__deploy:__ Use the AWS cli to update your s3 bucket and cloudfront distribution


Please replace __${domain}__ in __.gitlab-ci.yml__ by your blog domain!

### Manual pipeline steps

Replace __${domain}__ by your own domain name in all json files in the __deploy/__ folder. 
Go to gitlab.com and execute the pipelines in order:

1. createS3Bucket
2. createCloudFrontDistribution

After your cloudfront distribution has been created you will get a __distribution id__ and a __dns name__. 

Enter the __distribution id__ in __.gitlab-ci.yml__ as value of the variable __CLOUDFRONT_DIST_ID__. 

For DNS you need to create a __CNAME__ record from your blog domain to your new cloudfront domain name at your domain's DNS.

Next time you push to the master branch at your repo the automatic steps should be executed and your blog should be updated.
