# Active Directory Home Lab

A hands-on Windows Server 2022 Active Directory lab, built in VirtualBox to practice
real Tier 1 help desk tasks: account management, group membership, Group Policy,
and login troubleshooting.

> 🚧 **Work in progress.** I'm documenting every step, including the problems I hit
> and how I solved them.

## Lab at a glance

| Item | Detail |
|---|---|
| Hypervisor | Oracle VirtualBox 7 |
| Domain | `yardstick.local` |
| DC01 | Windows Server 2022, AD DS + DNS, `192.168.10.10` |
| PC-102 | Windows 11 Enterprise, `192.168.10.20` |
| Network | VirtualBox Internal Network `yardstick-lab` (`192.168.10.0/24`) |

## Progress

| Phase | Topic | Status |
|---|---|---|
| 1 | [Lab setup: DC01, DNS, domain join](docs/01-lab-setup.md) | 🟡 In progress |
| 2 | User management: create, reset password, unlock, disable | ⬜ Not started |
| 3 | Groups: add/remove membership | ⬜ Not started |
| 4 | Computer objects and trust relationships | ⬜ Not started |
| 5 | Group Policy: password and lockout policy | ⬜ Not started |
| 6 | Login troubleshooting with Event Viewer | ⬜ Not started |

## Problems I hit (so far)

| # | Problem | Root cause | Status |
|---|---|---|---|
| 1 | [VM failed to boot: "No bootable medium found"](docs/01-lab-setup.md#problem-1-vm-failed-to-boot) | ISO not attached to the optical drive | ✅ Fixed |
| 2 | [Black screen after boot](docs/01-lab-setup.md#problem-2-black-screen-after-boot) | Hyper-V on the host forced VirtualBox into slow Native API mode | ✅ Fixed |

## Repository layout

```
docs/          Step-by-step write-ups for each phase
screenshots/   Evidence for each step, grouped by phase
tickets/       Simulated help desk tickets (coming in Phase 2)
scripts/       PowerShell scripts (coming in Phase 2)
```

## Skills

Active Directory · DNS · Windows Server 2022 · Windows 11 · VirtualBox · PowerShell · Troubleshooting
