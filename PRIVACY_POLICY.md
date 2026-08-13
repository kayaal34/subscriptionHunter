# Privacy Policy — Subscription Hunter

**Last updated: 13 August 2026**

Subscription Hunter is built to work without an account and without sending your
data anywhere. This page explains exactly what the app stores, what leaves your
device, and what it does not do.

> **Publishing note (for the developer, remove before hosting):** Google Play
> requires a *publicly reachable URL* on the store listing — an in-app screen is
> not accepted on its own. Publish this file (GitHub Pages serves it for free)
> and put the resulting address in both the Play Console listing and
> `AppConstants.privacyPolicyUrl`.

## What the app stores

Everything you enter — subscription names, prices, billing dates, categories,
notes and reminder settings — is written to a database file inside the app's
private storage on your device. There is no account, no sign-in and no cloud
sync. We never receive a copy.

## What leaves your device

One thing only: to show a brand logo, the app asks Google's favicon service for
the icon of a public website, for example `netflix.com`. That request contains
the service's domain name and nothing else — no subscription prices, no personal
data, and no identifier for you or your device. Offline, the app draws a
coloured tile instead and works normally.

## Notifications

Payment reminders are scheduled by your device's own alarm system. They are
generated locally from the data you entered and never pass through a server.

## If you contact support

The support option opens your own email app with a message you can read and edit
before sending. It is pre-filled with the app version and your Android version
so a problem can be reproduced. If you send it, we receive your email address
and what you wrote, and use them only to answer you.

## What the app does not do

No analytics, no advertising, no tracking or profiling, no third-party marketing
SDKs, and no selling or sharing of data. There is nothing to sell — the data
never reaches us.

## Your control over your data

You can delete everything at any time from **Settings → Erase all data**.
Uninstalling the app also removes its database and settings from your device
permanently. Because no copy exists anywhere else, deletion is immediate and
final.

## Children

The app is a general-purpose budgeting tool, is not directed at children under
13, and no data is knowingly collected from them.

## Changes to this policy

If this policy changes, the "last updated" date above will change with it, and
the revised text will ship in the next app update.

## Contact

Questions about this policy can be sent to **kodmod034@gmail.com**.

---

## Data safety form — answers for the Play Console

For the "Data safety" section of the store listing:

| Question | Answer |
|---|---|
| Does your app collect or share any of the required user data types? | **No** |
| Is all of the user data collected by your app encrypted in transit? | Not applicable — no user data is transmitted |
| Do you provide a way for users to request that their data is deleted? | **Yes** — Settings → Erase all data, and uninstalling |

The only network request the app makes is to Google's favicon service for a
public website icon. It carries no user data, so it is not "data collection"
under the Play definition.
