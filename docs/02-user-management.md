# Phase 2: User Management

Goal: organize the domain with OUs, create user accounts, and practice the most common
Tier 1 tickets: new users, password resets, unlocks, and disabling leavers.

[← Back to README](../README.md)

## Progress

| Step | Task | Status |
| ---- | ---- | ------ |
| 1 | Create the OU structure | ✅ |
| 2 | Create the first user and test sign-in | ✅ |
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

## Step 2: Create the first user and test sign-in

New user in `Yardstick\Users\Accounting`:

| Field | Value |
|---|---|
| Name | John Smith |
| Logon name | `john.smith@yardstick.local` / `YARDSTICK\john.smith` |
| Password | Temporary, `<redacted>` |
| User must change password at next logon | ✅ |

![New user](../screenshots/02-users/02-new-user-name.png)
![Password options](../screenshots/02-users/03-new-user-password.png)

The temporary password means only the user knows their real password, not IT.

**Checking the account**

![Account tab](../screenshots/02-users/04-john-account-tab.png)

```powershell
Get-ADUser john.smith -Properties Enabled, LockedOut, PasswordLastSet, PasswordExpired, DistinguishedName
```

`PasswordExpired: True` is expected, because the password must be changed at first logon.
This is the first command I'd run when a user says they can't sign in.

![Get-ADUser](../screenshots/02-users/05-get-aduser-john.png)

**Signing in on PC-102**

John was forced to change his password on first sign-in, then signed in successfully.
His account exists only in AD, and DC01 authenticated him.

![Must change password](../screenshots/02-users/06-pc102-must-change-password.png)
![whoami as John](../screenshots/02-users/07-pc102-whoami-john.png)

Status: ✅ Done