# Phase 2: User Management

Goal: organize the domain with OUs, create user accounts, and practice the most common
Tier 1 tickets: new users, password resets, unlocks, and disabling leavers.

[← Back to README](../README.md)

## Progress

| Step | Task | Status |
| ---- | ---- | ------ |
| 1 | Create the OU structure | ✅ |
| 2 | Create the first user and test sign-in | ⬜ |
| 3 | Bulk-create users from CSV | ⬜ |
| 4 | Tickets: reset, unlock, disable | ⬜ |

---

## Step 1: Create the OU structure

The default **Users** and **Computers** folders are containers, not OUs.
You can't link Group Policy to a container, so I built my own OU structure:

```
yardstick.local
└── Yardstick
    ├── Users
    │   ├── Accounting
    │   ├── Sales
    │   └── IT
    ├── Computers
    ├── Groups
    └── Disabled Users
```

Each OU has *Protect from accidental deletion* turned on.

![OU structure](../screenshots/02-users/01-ou-structure.png)

Status: ✅ Done