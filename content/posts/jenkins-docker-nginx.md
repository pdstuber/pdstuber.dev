+++
title = "Setup jenkins in docker container with nginx as reverse proxy"
date = 2019-03-23T17:27:35+01:00
draft = false
tags = ["nginx", "docker", "jenkins"]
+++

## Install, enable, start  nginx

I believe not every single piece of code we write today has to run in a docker container.
So we're gonna just use the "classic" nginx.

```bash
$ sudo apt install nginx
$ sudo systemctl enable nginx.service
$ sudo systemctl start nginx.service
```

## Get a TLS certificate from letsencrypt

Install the letsencrypt certbot tool

```bash
$ sudo apt-get update
$ sudo apt-get install software-properties-common
$ sudo add-apt-repository universe
$ sudo add-apt-repository ppa:certbot/certbot
$ sudo apt-get update
$ sudo apt-get install certbot
```

Get a certificate:

```bash
$ sudo certbot certonly
```

Click through the wizard (I always use the nginx plugin) and when it's done you'll have a certificate under /etc/letsencrypt/live

## Configure nginx

__Delete the original config file, replace by new one__

```bash
$ sudo rm /etc/nginx/nginx.conf
$ sudo vim /etc/nginx/nginx.conf
```

__Use this:__

```nginx
events
{
  worker_connections 1024;
}

http
{
  include /etc/nginx/sites-enabled/*;
  server_names_hash_bucket_size 64;
  include /etc/nginx/mime.types;
  default_type application/octet-stream;
  sendfile on;
  keepalive_timeout 65;
  gzip on;

  # Redirect HTTP to HTTPS
  server
  {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    return 301 https://$host$request_uri;
  }
}
```

__Create the site config file:__

```bash
$ sudo vim /etc/nginx/sites-available/#FANCY_JENKINS_DOMAIN#
```

__Paste this:__

```nginx
upstream jenkins
{
  server 127.0.0.1:8080 fail_timeout=0;
}

server
{
  listen 443 ssl;
  # Replace jenkins.johndoe.com by your domain
  server_name jenkins.johndoe.com;
  ssl_certificate /etc/letsencrypt/live/jenkins.johndoe.com/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/jenkins.johndoe.com/privkey.pem;
  ssl_protocols TLSv1.2;
  ssl_ciphers HIGH:!aNULL:!MD5;

  location /
  {
    proxy_set_header Host $host:$server_port;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_pass http://jenkins;
  }
}
```

__Symlink to sites-enabled:__

```bash
$ sudo ln -s /etc/nginx/sites-available/#FANCY_JENKINS_DOMAIN# /etc/nginx/sites-enabled/#FANCY_JENKINS_DOMAIN#
```

__Reload nginx config__

```bash
$ sudo systemctl reload nginx.service
```

