# Openshift Pipelines Workshop

This is a workshop about Openshift Pipelines. 

## Prerequisites:
    - Openshift 4.x cluster
    - oc cli
    - git cli

## Setup

Define an environment variable GITHUB_USER:

```shell
export GITHUB_USER=your-username
```

Fork this repo: [Spring Rest Tekton Pipeline](https://github.com/paolocarta/spring-rest-tekton-pipeline)

In order to install the Openshift Pipelines Operator and clone the sample repo execute this script:

```shell
./setup.sh
```

## Steps

The first workshop steps can be found in the folder steps.
They are sorted with numbers.

## Example project

An example Spring Boot project will be cloned by the setup script.
The folder's name is "spring-rest-tekton-pipeline"

If you want to the the pipeline triggering you should register a webhook in your forked repo. The Webhook should point to your listener's route.

In order to get the route execute this command in the namespace basic-spring-boot-cicd (You should be there by default):

```shell
oc get route webhook-listener -ojsonpath='{.spec.host}'
```

