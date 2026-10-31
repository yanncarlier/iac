

```
Hardware virtualization (VT-x / AMD-V)
        └── KVM (kernel hypervisor)
              ├── VMMs (userspace)
              │     ├── QEMU (general VMs, plus microvm machine type)
              │     ├── Firecracker (minimal microVMs)
              │     └── Cloud Hypervisor (modern, minimal VMM)
              │
              └── (consumed by)

Orchestration layer
  └── Kata Containers → container runtime API (OCI/CRI) that launches
                        a VM per pod using QEMU, Cloud Hypervisor,
                        Firecracker, or Dragonball

Guest layer (what runs inside the VM)
  ├── Regular Linux guest (typical for Kata, QEMU, Firecracker)
  └── Unikraft unikernel → built/run with kraft, typically on
                           QEMU or Firecracker over KVM
```





| Dimension               | QEMU / QEMU microvm                                          | Firecracker                                                  | Kata Containers                                              |
| :---------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| Isolation               | VM isolation; conventional QEMU has a large device-emulation surface | Strong VM isolation with a deliberately tiny VMM/device model | VM isolation per container/pod, with a dedicated guest kernel. northflank+1 |
| Startup                 | Seconds for a typical VM; QEMU `microvm` is optimized for faster startup | About 125 ms to application code; can create up to 150 microVMs/sec/host in published benchmarks. usenix+1 | Roughly 150–300 ms depending on the selected VMM and configuration. northflank+1 |
| Memory overhead         | Higher than Firecracker; depends heavily on guest OS and devices | Under 5 MiB VMM overhead per microVM in AWS’s benchmark configuration. [usenix](https://www.usenix.org/system/files/nsdi20-paper-agache.pdf) | Higher than raw Firecracker because each workload has its own guest kernel and VM context. [bigiron](https://www.bigiron.cc/guides/gvisor-vs-kata-vs-firecracker-the-isolation-layer-decision) |
| Hardware/device support | Broadest: many architectures, legacy devices, GPU/VFIO passthrough, graphics, USB, etc. | Intentionally limited: no graphics, USB, BIOS, ACPI, VFIO/passthrough, or device hotplug. northflank+1 | Depends on backend; QEMU backend gives the broadest compatibility, Firecracker backend is much more constrained. [github](https://github.com/kata-containers/kata-containers/blob/main/docs/design/virtualization.md) |
| Kubernetes integration  | You build the VM workflow yourself                           | You build the orchestration/control plane yourself           | Native container/Kubernetes workflow via CRI and RuntimeClass. northflank+1 |
| Operational complexity  | Moderate to high; mature but feature-rich                    | High if used raw: no built-in VM lifecycle, networking, storage, scheduling, or image management | Lower for Kubernetes teams; it integrates with existing container tooling. usenix+1 |
| Best for                | Desktop/lab VMs, cross-architecture testing, GPU/VFIO, legacy systems, maximum flexibility | Serverless/FaaS, CI sandboxes, AI-agent code execution, multi-tenant ephemeral workloads | Strong isolation for Kubernetes workloads while retaining container ergonomics. northflank+1 |

## Unikraft / kraft

[Unikraft](https://unikraft.org/docs/concepts) is an alternative system for running applications in the cloud. In production it feels like managing traditional containers, but the application is packaged and executed as a **unikernel**: a single-address-space binary that contains only the OS components the application actually needs, with no separation between kernel and user address spaces. That gives container-like size and startup with VM-grade, hardware-enforced isolation. It can run on a hypervisor (KVM, Xen, VMware) or bare metal.

`kraft` is the command-line companion tool that builds and runs unikernels, and it also handles packaging, instances, and Compose-style deployments.

| Dimension               | Unikraft / kraft                                                                 |
| :---------------------- | :------------------------------------------------------------------------------- |
| Isolation               | VM-level isolation from hardware virtualization primitives; a single-address-space libOS reduces the attack surface to just the included components |
| Startup                 | Milliseconds; the image boots straight into the application                      |
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