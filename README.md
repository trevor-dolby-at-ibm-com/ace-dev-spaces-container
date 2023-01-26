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
# ace-vnc-devcontainer

Toolkit-enabled codespaces container for ACE v12

## Background

Codespaces are a [feature of GitHub](https://github.com/features/codespaces) that enables
container-based development with VisualStudio Code in a web browser. The container in
which vscode runs is configurable, and this repo uses a container with ACE installed.

Developers get sixty hours of container runtime for free (at the time of
writing), and a codespace can be launched from the "Code" menu:

![Codespaces launch](/files/codespaces-launch.png)

ACE v12 can be run in a codespace using containers from [ace-docker](https://github.com/trevor-dolby-at-ibm-com/ace-docker/tree/main/experimental/devcontainers)
but those containers are intended for command-line use in conjunction with vscode. This
container allows the use of the toolkit without any need to install anything locally.

The main additions are
- An X-Windows server to be used by the toolkit GUI
- A VNC server that allows VNC clients to access the X-Windows desktop
- A VNC client that runs in a browser and can connect to the VNC server

## Building

The container should be built using the ACE developer edition and pushed to a public 
repository; there are containers under tdolby/experimental on dockerhub but these should
not be relied upon to stay around and/or work at all.

```
docker build -t ace-devcontainer-xvnc:12.0.4.0 -f Dockerfile.xvnc .
```
followed by tagging and pushing the container. The resulting public image tag should be 
used in the configuration below instead of the experimental image shown.

## Application repo setup

Codespace configurations are held in the .devcontainer directory of the repo containing
the ACE projects rather than being configured in a separate repo. These instructions will
use the example at https://github.com/tdolby-at-uk-ibm-com/ace-bdd-cucumber to illustrate
usage.

The [devcontainer.json](https://github.com/tdolby-at-uk-ibm-com/ace-bdd-cucumber/blob/main/.devcontainer/devcontainer.json)
file should contain something like 
```
{
    "name": "ace-bdd-cucumber-devcontainer",
    "image": "tdolby/experimental:ace-devcontainer-xvnc-12.0.7.0",
    "containerEnv": {
        "LICENSE": "accept"
    },
    "remoteEnv": {
        "REMOTE_LICENSE": "accept"
    }
}
```
to instruct the codespaces runtime to load the `tdolby/experimental:ace-devcontainer-xvnc-12.0.7.0` container
(the name should be changed to match the container built earlier (see above)) and the license must be accepted 
for the product to work correctly.

## Starting the toolkit

Once the application repo is set up correctly, it should be possible to launch the codespace container from
the "code" menu (see picture above) and start it downloading the image; this may take some
time, and clicking on "view logs" should show something like

![Codespaces startup](/files/vnc-codespace-setting-up.png)

Once the container is up and running, the ACE command line will be available as usual in the terminal window
so commands like `mqsilist` will run as expected. Running the toolkit takes a few more steps, starting with
launching X-Windows and VNC servers using the `run-vnc.sh` script:

![server startup](/files/vnc-codespace-start-xvnc.png)

Enter a password at the prompt, say "no" the the view-only password, and the server should then start in the
background. A pop-up is likely to appear stating that a server is listening on port 5901, but this is not the
port we need to use and so instead the "PORTS" tab should be selected so that we can select port 6080 and 
follow the link in the browser:

![server startup](/files/vnc-codespace-port-6080.png)

This page is a directory, and the `vnc.html` page is the one we need to gain access to VNC:

![vnc page](/files/vnc-codespace-vnc-html.png)

This page will have a "connect" button which will connect to the VNC server, at which point the password
entered earlier will be needed to access the virtual X-Windows desktop. Right-clicking on the background
will allow a terminal to be launched, and the ACE product is in /opt/ibm/ace-12 so running

```
/opt/ibm/ace-12/ace tools
```
will bring up the toolkit.

## Importing the projects

The toolkit will not have any projects visible by default, as these are in the codespaces-provided /workspaces
directory rather than in an Eclipse workspace. The projects need to be imported without copying, as the goal
is to allow git to push changes back to the repo without any further setup (as normally happens with vscode).

Right-clicking on the white background of the "Application Devleopment" pain shows the "import" option

![vnc page](/files/vnc-codespace-import-select.png)

which leads to the import wizard page where "Existing projects into Workspace" is the correct choice:

![vnc page](/files/vnc-codespace-import-existing.png)

The correct location is the repo directory under /workspaces:

![vnc page](/files/vnc-codespace-import-location.png)

and after the import is complete then the projects should work as they do on a local system: test projects
can be run, changes made to flows and code, etc.

Changes made in the toolkit should appear in the git perspective and can be pushed to the repo from the 
toolkit or from the vscode editor (or the git command line).
