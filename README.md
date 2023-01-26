# ace-dev-spaces-container

OpenShift Dev Spaces container with ACE v12 and MQ client. Built on top of the 
standard RedHat Universal Developer Image (udi-rhel8).  See https://developers.redhat.com/crw-fmi 
for more information on the base image and Dev Spaces.

These images can be built and pushed to dockerhub or any other container registry, and
will be pulled down automatically when starting a workspace.

## Dockerfiles

- [Dockerfile](Dockerfile) contains an ACE image plus an MQ client, without the toolkit.

## Usage

Create a `.devfile.yaml` file in the root directory of a repo with contents similar to the following:

```
apiVersion: 1.0.0
metadata:
  name: ace-demo-sap-unittest
projects:
  - name: ace-demo-sap-unittest
    source:
      type: git
      location: 'https://github.com/tdolby-at-uk-ibm-com/ace-demo-sap-unittest'
components:
  - alias: ace-v12
    type: dockerimage
    image: 'tdolby/experimental:ace-dev-spaces-container-12.0.4.0'
    memoryLimit: 2048Mi
    env:
      - name: LICENSE
        value: accept
    endpoints:
      - name: server
        port: 7600
        attributes:
          discoverable: 'true'
          public: 'true'
          protocol: 'http'
    mountSources: true
```
replacing the image name with the location of the container built from the
Dockerfile in this repo, and the "location" field with the GitHub repo name.

The Dev Spaces infrastructure will handle cloning the GitHub repo into the 
workspace, and so GitLab and other source code repositories can also be used,
depending on the configuration of the Dev Spaces environment itself.
# Dev Spaces

Dev Spaces are a [feature of OpenShift](https://developers.redhat.com/crw-fmi) that enables
container-based development with VisualStudio Code in a web browser. The container in
which vscode runs is configurable, and this repo uses a container with ACE installed.

An OpenShift cluster is required and the Dev Spaces operator must be installed:

![Dev Spaces operator](/images/dev-spaces-operator.png)

Once the operator is installed, a workspace can be created to build and run ACE projects.
If the operator is newly-installed, then creating an empty workspace to begin with is a
good way to ensure the operator is working as expected:

![Empty Workspace](/images/dev-spaces-empty-workspace.png)

Once that has succeeded, it should be deleted and a new ACE workspace created by pasting
the URL of this repo (`https://github.com/tdolby-at-uk-ibm-com/ace-demo-sap-unittest`)
into the `Git Repo URL` field of the the `Create Workspace` page:

![git URL](/images/dev-spaces-create-workspace.png)


## Building and testing

The container will start up once the image has been downloaded and vscode will start
automatically. A terminal window is needed to run Maven or other commands, and this 
can be launched from the menu in the top left corner:

![new terminal](/images/dev-spaces-new-terminal.png)

All of the usual ACE commands are present, servers can be started as usual, etc. For this
repo, Maven can be used to build and test the application in the terminal window:
```
mvn --no-transfer-progress verify
```
The first Maven run will download lots of plugins, and subsequent runs will be faster.

The `build-and-ut.sh` script also works, and does not require Maven.

## Use cases

As the ACE toolkit is not available (the web console is taken up with vscode and there is
no X-Windows display), Dev Spaces are most useful for incremental coding and fixing issues.
Although it is possible to create message flows with a text editor, and this is supported
as long as the format is exactly right, the toolkit is a much more efficient way to do this!

For ESQL or Java coding, unit testing, or fixing CI build breaks, Dev Spaces provide an
easy-to-start environment that removes the need to install the product locally while still
allowing building and testing with the actual product.

## Dev Spaces container

The workspaces for this repo use the [ace MQ client container](https://github.com/trevor-dolby-at-ibm-com/ace-dev-spaces-container)
which is built on the standard RedHat Universal Developer Image with ACE, MQ client, and Maven installed.
