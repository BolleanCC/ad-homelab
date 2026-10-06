# Phase 1: Lab Setup

Goal: build a domain controller (`DC01`) and a Windows 11 client (`PC-102`),
create the `yardstick.local` domain, and join the client to it.

[← Back to README](../README.md)

## Lab design

| Machine | Role | IP | DNS |
|---|---|---|---|
| DC01 | Domain controller, DNS | 192.168.10.10 | 127.0.0.1 |
| PC-102 | Domain client | 192.168.10.20 | 192.168.10.10 |

Both VMs use a VirtualBox **Internal Network** named `yardstick-lab`.
They can reach each other, but not my home network, like a small isolated office LAN.

---

## Step 1: Create the DC01 VM

| Setting | Value | Why |
|---|---|---|
| Name | DC01 | Name it before promotion. Renaming a DC later is risky. |
| ISO | Windows Server 2022 Evaluation | Free 180-day evaluation from Microsoft |
| Unattended install | Off | So I can choose the Desktop Experience edition myself |
| Memory | 4096 MB | Enough for a small lab DC |
| CPUs | 2 | |
| Disk | 50 GB, dynamically allocated | Uses real disk space only as data is written |
| Boot order | Optical before Hard Disk | Boot from the ISO first |
| Network | Internal Network `yardstick-lab` | Isolated lab network |

Status: ✅ Done

---

## Step 2: Install Windows Server 2022

Status: 🟡 In progress. The two boot problems below are fixed, and the installer now loads.

---

## Troubleshooting

Each problem follows the same format I'd use in a real ticket:
**Symptom → Evidence → Cause → Fix → Result**.

### Problem 1: VM failed to boot

**Symptom**

The VM stopped with *"No bootable medium found! Please insert a bootable medium and reboot."*

![No bootable medium found](../screenshots/01-setup/problem-01-no-bootable-medium.png)

**Evidence**

The DVD field in the dialog showed `<not selected>`, so nothing was in the virtual optical drive.

**Cause**

The Windows Server ISO was not attached to the VM's optical drive.
With an empty hard disk and an empty DVD drive, there was nothing to boot from.

**Fix**

1. Powered off the VM.
2. `Settings > Storage`: attached `Windows_Server_2022.iso` to the optical drive.
3. `Settings > System`: confirmed **Optical** boots before **Hard Disk**.

**Note**

The same error also appears if you miss the *"Press any key to boot from CD or DVD"* prompt.
The installer only waits a few seconds, then falls through to the empty hard disk.
**One error message can have more than one cause.**

---

### Problem 2: Black screen after boot

**Symptom**

After the ISO was attached, the VM showed only a black screen.
The VirtualBox status bar showed a green turtle icon with constant CPU activity.

![Black screen](../screenshots/01-setup/problem-02-black-screen.png)

**Evidence**

`Machine > Session Information > Runtime Information`:

| Field | Value | Meaning |
|---|---|---|
| VM Execution Engine | `native API` | VirtualBox is going through Hyper-V instead of using VT-x directly |
| Nested Paging | Inactive | Hardware acceleration is not in use |
| Screen Resolution | `0x0` | The virtual display never initialized |

![Session information showing native API](../screenshots/01-setup/problem-02-native-api.png)

**Cause**

Hyper-V was running on the host. When Hyper-V is active, it owns the CPU's virtualization
features, so VirtualBox falls back to the much slower Native API mode.

**Fix**

All changes were made on the host, not inside the VM.

1. Turned off the Windows hypervisor at boot:

   ```powershell
   # Run as Administrator
   bcdedit /set hypervisorlaunchtype off
   ```

   ![bcdedit completed successfully](../screenshots/01-setup/problem-02-fix-01-bcdedit.png)

2. Turned off **Memory Integrity** in Windows Security > Device security > Core isolation.
   Memory Integrity uses virtualization-based security, which also keeps the hypervisor running.

   | Before | After |
   |---|---|
   | ![Memory integrity on](../screenshots/01-setup/problem-02-fix-02-memory-integrity-on.png) | ![Memory integrity off](../screenshots/01-setup/problem-02-fix-03-memory-integrity-off.png) |

3. Disabled these Windows features: Hyper-V, Virtual Machine Platform, Windows Hypervisor Platform.
4. Rebooted the host.

**Security trade-off**

Turning off Memory Integrity lowers the host's protection against malicious kernel drivers.
It does not affect RAM. I accepted this for my personal lab machine, kept Defender and
Windows Update on, and documented how to undo it:

- `bcdedit /set hypervisorlaunchtype auto`
- Turn Memory Integrity back on
- Reboot

On a company laptop, I would not change a security setting like this without approval.

**Side note: landed in the UEFI setup menu**

After the reboot, I pressed keys repeatedly to catch the *"Press any key to boot from CD or DVD"*
prompt. One of the keys opened the VM's UEFI firmware menu instead.
I used **Boot Manager** to select the CD-ROM and pressed a key **once** at the prompt.


**Result**

VirtualBox now uses hardware virtualization directly.
The status bar shows the VT-x icon instead of the turtle.

| Field | Before | After |
|---|---|---|
| VM Execution Engine | native API | VT-x/AMD-V |
| Nested Paging | Inactive | Active |
| Unrestricted Execution | Inactive | Active |
| Screen Resolution | 0x0 | 1280x800x32 |

The VM boots from the ISO normally in UEFI mode, so switching back to BIOS was not needed.

"Paravirtualization Interface: Hyper-V" is still shown. That's expected: it's an interface
VirtualBox presents to Windows guests for better performance. It is not the host's Hyper-V.

![Execution engine now VT-x](../screenshots/01-setup/problem-02-fix-05-vtx.png)

**Lesson**

The symptom was inside the VM, but the root cause was on the host.
I confirmed the cause with evidence before changing anything,
and I verified the fix with the same evidence afterward.
