https://unikraft.org/docs/

## Unikraft / kraft

[Unikraft](https://unikraft.org/docs/concepts) is an alternative system for running applications in the cloud. In production it feels like managing traditional containers, but the application is packaged and executed as a **unikernel**: a single-address-space binary that contains only the OS components the application actually needs, with no separation between kernel and user address spaces. That gives container-like size and startup with VM-grade, hardware-enforced isolation. It can run on a hypervisor (KVM, Xen, VMware) or bare metal.

`kraft` is the command-line companion tool that builds and runs unikernels, and it also handles packaging, instances, and Compose-style deployments.

| Dimension               | Unikraft / kraft                                             |
| :---------------------- | :----------------------------------------------------------- |
| Isolation               | VM-level isolation from hardware virtualization primitives; a single-address-space libOS reduces the attack surface to just the included components |
| Startup                 | Milliseconds; the image boots straight into the application  |
| Memory overhead         | Light: image size is comparable to a container, and only the required libraries are linked in |
| Hardware/device support | Only the drivers and features selected at build time (KConfig); no unused legacy devices |
| Kubernetes integration  | Runs as a VM/unikernel workload; kraft provides build, run, and compose workflows |
| Operational complexity  | Low day-to-day (container-like commands), but applications must be built for Unikraft |
| Best for                | Serverless/FaaS, microservices, edge, and any workload where fast boot, small footprint, and strong isolation all matter |

```sh
# install kraft
curl -sSfL https://get.kraftkit.sh | sh

kraft run unikraft.org/helloworld:latest
kraft run -p 8080:80 unikraft.org/nginx:latest
kraft run .                      # build from a local Kraftfile/Dockerfile
kraft ps --all
kraft logs <instance-id-or-name>
kraft stop <instance-id-or-name>
kraft rm <instance-id-or-name>
```



curl -sSfL https://get.kraftkit.sh | sh  



kraft run unikraft.org/helloworld:latest  

kraft run -p 8080:80 unikraft.org/nginx:latest  

kraft run .

kraft ps --all

kraft logs <instance-id-or-name>

kraft stop <instance-id-or-name>

kraft rm <instance-id-or-name>

kraft pkg ls --update --apps



Here is an example compose.yaml file:

```
version: '3.8'

services:
  app:
    # Points to a folder with a Kraftfile/Dockerfile combo
    build: ./my-app-folder
    ports:
      - "8080:8080"
    environment:
      - DB_HOST=database
    depends_on:
      - database

  database:
    # Pulls a pre-built isolated microVM from the Unikraft catalog
    image: unikraft.org/redis:latest
    ports:
      - "6379:6379"

```

kraft compose up -d  

kraft compose logs  

kraft compose down  