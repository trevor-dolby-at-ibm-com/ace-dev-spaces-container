# ace-dev-spaces-container

Dev Spaces are a [feature of OpenShift](https://developers.redhat.com/crw-fmi) that enables
container-based development with VisualStudio Code in a web browser. The container in
which vscode runs is configurable, and this repo provides Dockerfiles to create containers 
with ACE installed that can be used with Dev Spaces.

The containers are built on top of the standard RedHat Universal Developer Image (udi-rhel8).
See https://developers.redhat.com/crw-fmi for more information on the base image and Dev Spaces.

These images can be built and pushed to dockerhub or any other container registry, and
will be pulled down automatically when starting a workspace. The workspace must point to 
a source repo that is configured for Dev Spaces (for example, has a `.devfile.yaml`), at
which point the infrastructure will take care of downloading the image, pulling in the
source repo, and starting the Dev Spaces container. Note that in some cases GitHub 
authentication must be enabled at the infrastructure level in order to eliminate the need 
to log into GitHub from the container; see Dev Spaces documentation for more information.

## OpenShift requirements

An OpenShift cluster is required and the Dev Spaces operator must be installed:

![Dev Spaces operator](/images/dev-spaces-operator.png)

Once the operator is installed, a workspace can be created to build and run ACE projects.
If the operator is newly-installed, then creating an empty workspace to begin with is a
good way to ensure the operator is working as expected:

![Empty Workspace](/images/dev-spaces-empty-workspace.png)

## Dockerfiles and container building

- [Dockerfile](Dockerfile) contains an ACE image plus an MQ client, without the toolkit.
- [Dockerfile.xvnc](Dockerfile.xvnc) contains a complete ACE image plus an MQ client, plus remote desktop enablement:
  - An X-Windows server to be used by the toolkit GUI
  - A VNC server that allows VNC clients to access the X-Windows desktop
  - A VNC client that runs in a browser and can connect to the VNC server

The container should be built using the ACE developer edition and pushed to an accessible 
repository (for example, the OpenShift container registry); there are containers under 
tdolby/experimental on dockerhub but these should not be relied upon to stay around and/or
work at all.

Run 
```
docker build -t ace-dev-spaces-container-12.0.4.0 -f Dockerfile .
```
and/or
```
docker build -t ace-dev-spaces-container-xvnc-12.0.4.0 -f Dockerfile.xvnc .
```

followed by tagging and pushing the container. The resulting public image tag should be 
used in the configuration below instead of the experimental image shown.

## GitHub repo enablement

Create a `.devfile.yaml` file in the root directory of a repo with contents similar to 
the following (for a non-toolkit Dev Space):

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
See https://github.com/tdolby-at-uk-ibm-com/ace-bdd-cucumber/blob/main/.devfile.yaml
for an equivalent toolkit-enabled example, which uses the `-xvnc` container
variant with a different workspace name and URL.

The Dev Spaces infrastructure will handle cloning the GitHub repo into the 
workspace, and so GitLab and other source code repositories can also be used,
depending on the configuration of the Dev Spaces environment itself.

## Usage

Once the above steps have succeeded, a new ACE workspace should be created by pasting
the URL of the enabled GitHub repo (for example, `https://github.com/tdolby-at-uk-ibm-com/ace-demo-sap-unittest`
or `https://github.com/tdolby-at-uk-ibm-com/ace-bdd-cucumber`) into the `Git Repo URL`
field of the the `Create Workspace` page:

![git URL](/images/dev-spaces-create-workspace.png)


## Building and testing with vscode and commands

The container will start up once the image has been downloaded and vscode will start
automatically. A terminal window is needed to run Maven or other commands, and this 
can be launched from the menu in the top left corner:

![new terminal](/images/dev-spaces-new-terminal.png)

All of the usual ACE commands are present, servers can be started as usual, etc. For 
the [ace-demo-sap-unittest](https://github.com/tdolby-at-uk-ibm-com/ace-demo-sap-unittest)
repo, Maven can be used to build and test the application in the terminal window:
```
mvn --no-transfer-progress verify
```
The first Maven run will download lots of plugins, and subsequent runs will be faster.

The `build-and-ut.sh` script also works, and does not require Maven.

The [ace-bdd-cucumber](https://github.com/tdolby-at-uk-ibm-com/ace-bdd-cucumber) repo has
an equivalent script named `build-and-run-tests.sh` that can be run from the Terminal.

### Non-toolkit use cases

As the ACE toolkit is not available, the non-toolkit Dev Spaces are most useful for 
incremental coding and fixing issues. Although it is possible to create message flows 
with a text editor, and this is supported as long as the format is exactly right, the
toolkit is a much more efficient way to do this!

For ESQL or Java coding, unit testing, or fixing CI build breaks, non-toolkit Dev Spaces
provide an easy-to-start environment (Smaller than toolkit-enabled containers) that
removes the need to install the product locally while still allowing building and testing
with the actual product.

## Using the toolkit

Once the application repo is set up correctly with the `ace-dev-spaces-container-xvnc` 
container variant (see https://github.com/tdolby-at-uk-ibm-com/ace-bdd-cucumber for a
toolkit-enabled example), and once the container is up and running, the ACE command line will be
available as usual in the terminal window so commands like `mqsilist` will run as expected.
Running the toolkit takes a few more steps, starting with launching X-Windows and VNC servers
using the `run-vnc.sh` script:

![server startup](/images/dev-spaces-vnc-start.png)

Enter a password at the prompt, say "no" the the view-only password, and the server should then
start in the background. A pop-up is likely to appear stating that a server is listening on port
5901 (and/or port 6080) but the vscode port forwarding does not seem to work with OpenShift routes
and so the pop-ups should be ignored. The correct URL is printed out by the script, and should
look similar to the following:
```
========================================================================


Connect to one of the following URLs to access the virtual desktop:
https://workspace64f96588ef374454-2.apps.openshift-cluster.provider.com
http://workspace64f96588ef374454-2.apps.openshift-cluster.provider.com


========================================================================
```
where the choice of https or http depends on the Dev Space infrastructure configuration.

Once the correct URL has been determined, the resulting page will have a "connect" button
which will connect to the VNC server, at which point the password entered earlier will be
needed to access the virtual X-Windows desktop. A terminal window should already be started,
and the ACE product is in /opt/ibm/ace-12 so running

```
/opt/ibm/ace-12/ace tools
```
will bring up the toolkit. 

Note that there seems to be an issue with fonts for the toolkit, with the UDI image not 
providing everything needed; this does not affect functionality but may make some menus
and windows look oddly-spaced.

## Importing the projects

The toolkit will not have any projects visible by default, as these are in the provided 
`/projects` directory rather than in an Eclipse workspace. The projects need to be imported 
without copying, as the goal is to allow git to push changes back to the repo without any 
further setup (as normally happens with vscode).

Right-clicking on the white background of the "Application Development" pain shows the "import" option

![vnc page](/images/dev-spaces-import-select.png)

which leads to the import wizard page where "Existing projects into Workspace" is the correct choice:

![vnc page](/images/dev-spaces-import-existing.png)

The correct location is the repo directory under /projects:

![vnc page](/images/dev-spaces-import-location.png)

and after the import is complete then the projects should work as they do on a local system: test projects
can be run, changes made to flows and code, etc.

Changes made in the toolkit should appear in the git perspective and can be pushed to the repo from the 
toolkit or from the vscode editor (or the git command line), assuming git authentication has been
configured (which may involve Dev Spaces configuration changes).
