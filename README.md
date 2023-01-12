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
      location: 'https://github.com/trevor-dolby-at-ibm-com/ace-demo-sap-unittest'
components:
  - alias: ace-v12
    type: dockerimage
    image: 'tdolby/experimental:ace-dev-spaces-container-12.0.7.0'
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
