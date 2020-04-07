# Tekton-Playground

This repo is about to test Tekton pipelines using a real example of the Petclinic repo. It is [based on my current repository](https://github.com/dcanadillas/petclinic-kaniko) that builds Spring Petclinic application using Kaniko in a Jenkins pipeline executed in Kubernetes.

So, this example of Tekton pipelines build the Spring Petclinic as follows:
- Creates a Tekton task to build the application using Maven
- Creates a Tekton taskt to build the container using Kaniko
- Creates a Tekton task to deploy the container in the Kubernetes namespace (we are using the Tekton one as default)
- Define and creates the Tekton `pipeline` to orchestrate previous defined tasks
- Creates the `pipelineresources` object to be used as inputs and outputs of the tasks
- Run the pipeline through the `pipelinerun` object than instantiate the pipeline to be run

## Structure of this repo

One of the main Tekton advantages, among others, is the ability of decoupling stages of a pipeline (Tekton tasks), so it is possible to run isolated and parametrized. Then, a pipeline is a way to orchestrate different tasks depending on the use case.

So, in this repo we will find the following files/directories where required Tekton definitions and Kubernetes objects are defined:
- `petclinic-pipeline.yaml`: This is the YAML file with Tekton tasks and Pipeline definition
- `petclinic-resources.yaml`: Tekton resources defined in one YAML file
- `petclinic-run.yaml`: Pipelinerun to instantiate the pipeline defined in the rest of the files
- `deploy-serviceaccount.yaml`: YAML file to create RBAC permissions to deploy
- `taskruns`: Directory to find some `TaskRuns` to deploy isolated Tekton `Tasks`

## Configuration Pre-requisites

In order to execute the Tekton pipelines in this repo it is required to create some specific resources and take some considerations:
- Create or own a Kubernetes cluster (you can use [the $300 GCP Free Tier](https://cloud.google.com/free/) to test with your own [GKE](https://cloud.google.com/kubernetes-engine/) cluster)
- [Install Tekton pipelines](https://github.com/tektoncd/pipeline/blob/master/docs/install.md) in your created Kubernetes cluster
- Create the `Kubernetes secret` to publish the docker container in your own `Docker Registry`
- Change the `PipelineResource` to specify the container image url you want to use and have access to
- Deploy a `ServiceAccount`, a `Role` and a`RoleBinding` to give permissions to deploy the Spring Petclinic application in the namespace (this repo configuration is using by default the same where Tekton pipelines is deployed, but I recommend to change it)
- If you use a different container registry than GCR, change the `test-deploy-secret.yaml` file to use your 

### Creating kubernetes secrets

To create the required kubernetes secret you can do it by executing the following `kubectl` command (replace your parameters):
```
$ kubectl create secret docker-registry kaniko-secret-cfg \
--docker.username=<your_docker_registry_user> \
--docker.password=<your_password> \
--docker.email=<your_valid_email> \
--docker.server=<your_docker_registry>
```

If you use your own [Google Container Registry](https://cloud.google.com/container-registry/) you should create a key for your Google service account, download the `JSON` file and load it into the secret. It can be done by (assuming that your key json file is in ./kaniko-secret.json):
```bash
$ kubectl create secret docker-registry kaniko-secret-cfg \
--docker.username=_json_key \
--docker.password= $(cat ./kaniko-secret.json)\ 
--docker.email=<your_valid_email> \
--docker.server=gct.io/<your_gcp_project>
```

### Creating deployment service account

The pipeline to show in this repo is executing three tasks, being the last one (`deploy-kubectl`) a deployment of the built application in the Kubernetes cluster. To deploy using `kubectl` in the default namespace you need to create the specific `serviceAccount` with the required permissions. To do that you can use the file `deploy-serviceaccount.yaml` included is this repo. Just execute:

```bash
$ kubectl apply -f deploy-serviceaccount.yaml -n tekton-pipelines
```

### Change to your own Docker image to push

You need to change the `PipelineResource` where the image to be pushed is specified in the `petclinic-resources.yaml` file:

```bash
$ export MY_DOCKER_IMG=<your_registry>/<your_image>:latest
$ cat petclinic-resources.yaml | \
sed "s%gcr.io\/ci-cd-playground\/petclinic-kaniko\:latest%$MY_DOCKER_IMG%g" | \
tee petclinic-resources.yaml
```

## Testing and running Tekton pipelines

Once everything is configured, following commands will deploy the *pipeline and resources*:

```bash
$ kubectl apply -f petclinic-pipeline.yaml,petclinic-resources.yaml
```

You should get an output like:
```
task.tekton.dev/build-maven created
task.tekton.dev/build-kaniko created
task.tekton.dev/deploy-kubectl created
pipeline.tekton.dev/petclinic-pipeline created
pipelineresource.tekton.dev/petclinic-git created
pipelineresource.tekton.dev/petclinic-image created
pipelineresource.tekton.dev/petclinic-deploy created
```

Then you can see the Tekton objects by running:
```bash
$ kubectl get tasks,pipelines,pipelineresources
```

So, you should see the follwowing Kubernetes CRDs objects:
```
NAME                             AGE
task.tekton.dev/build-kaniko     1m
task.tekton.dev/build-maven      1m
task.tekton.dev/deploy-kubectl   1m

NAME                                     AGE
pipeline.tekton.dev/petclinic-pipeline   1m

NAME                                           AGE
pipelineresource.tekton.dev/petclinic-deploy   1m
pipelineresource.tekton.dev/petclinic-git      1m
pipelineresource.tekton.dev/petclinic-image    1m
```

### Running the pipeline

Once all `Tasks`, `PipelineResources` and `Pipeline` is deployed into the Kubernetes cluster, the only thing to do to run de Tekton pipeline is to deploye the `PipelineRun` object definition:

```bash
$ kubectl apply -f petclinic-run.yaml
```
You should see the successful output of the object created:
```
pipelinerun.tekton.dev/petclinic-pipelinerun created
```

Now, your pipeline should be running. You can see how pods and containers are being executed:

```bash
$ kubectl get pods
```
```
NAME                                                     READY   STATUS      RESTARTS   AGE
petclinic-pipelinerun-petclinic-maven-7d8ld-pod-9ab76d   0/6     Init:0/3    0          7s
tekton-pipelines-controller-5b5dd5c45-cr8ms              1/1     Running     0          3d
tekton-pipelines-webhook-84f498d964-l56kv                1/1     Running     0          3d
```

