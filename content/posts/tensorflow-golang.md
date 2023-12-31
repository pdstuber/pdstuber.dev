+++
title = "Is it a cat? Deploying a machine learning application as microservices"
date = 2020-04-25T17:56:02+02:00
draft = false
tags = ["tensorflow", "golang", "Vue.js"]
+++

# Introduction

This post describes how to setup a simple image classification service using tensorflow/keras and a set of golang microservices, that can be deployed on kubernetes.

For showcasing this I decided to make a simple webpage which allows you to upload a picture and predicts whether the uploaded image shows a cat or not.

The code can be found on [gitlab](https://gitlab.com/pdstuber)
# Services

__isit-a-cat__ consists of 3 golang microservices and the python code for machine learning part.

- __isit-a-cat-front__: Vue.js application where you can upload a picture and see if it's a cat or not
- __isit-a-cat-bff__: Backend for Frontend service that handles RESTful HTTP requests from the frontend and delegates work to the prediction service via NATS messaging
- __isit-a-cat-predict__: Uses the golang tensorflow bindings to load the tensorflow model and make a prediction on a given picture
- __isit-a-cat-learn__: the python machine learning code


## isit-a-cat-front

The frontend consists of a single Vue.js component with a file input for uploading an image and a text field to display the prediction result. The selected image is preprocessed (resized and compressed) and forwarded to the __isit-a-cat-bff__ service. A websocket is created to get the prediction results as soon as they're available.

Code: [gitlab](https://gitlab.com/pdstuber/isit-a-cat-front)


## isit-a-cat-bff

The Backend for Frontend service offers endpoints for uploading an image as a HTTP multipart form and registering for prediction results as websocket. The uploaded images are stored in a google cloud storage bucket, the prediction is retrieved from the __isit-a-cat-predict__ service via messaging.

Code: [gitlab](https://gitlab.com/pdstuber/isit-a-cat-bff)

## isit-a-cat-predict

the prediction service listens for messages on the predictions topic. On startup it fetches a exported tensorflow model from google cloud storage (which was trained with the __isit-a-cat-learn__ service), loads the model and restores the graph. On an incoming message it converts the image to a tensor, sets it as input to the graph, runs the prediction in a tensorflow session and takes the prediction result from the output. Then it creates a prediction result message of the class with maximum probability and pushes the message to the replyTo topic of the service instance of __isit-a-cat-bff__ waiting for the response.

Code: [gitlab](https://gitlab.com/pdstuber/isit-a-cat-predict-go)

## isit-a-cat-learn

The learning service is a python script which is using tensorflow and keras to train a neural network to detect cats on images.

Steps:

1. Load pre-trained model. We are using [VGG16](https://keras.io/api/applications/vgg/) here, which is pre-trained on the imagenet
2. Mark pre-trained layers as not trainable
3. Add new densely-connected layers to train this specifically for our cat-detection use-case. 
4. Train. I choose 10 epocs with a batch size of 128. My training set consists of 12265 cats and 12265 non cats. 20% of those are used for the validation phase. This is taking hours on an average laptop. That's why I mainly used a cloud virtual machine with a NVIDIA Tesla P100 GPU. It reduces the training time to under 30 minutes.

Code: [gitlab](https://gitlab.com/pdstuber/isit-a-cat-learn)

## Try it out

Everything needed for bootstrapping and running the application can be found here: [gitlab](https://gitlab.com/pdstuber/isit-a-cat-master)