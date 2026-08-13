# Outstanding work

Honest list of what is *not* done. Everything not listed here is implemented
and covered by tests.

## Known gaps

- [ ] **Currency conversion.** Totals are grouped by currency because there is
      no exchange-rate source. A user with subscriptions in both TRY and USD
      sees two figures, not one combined total. Adding an FX provider with an
      offline cache would close this.
- [ ] **The logo provider is an unowned dependency.** Brand logos come from
      Google's favicon endpoint, which has no SLA. Failures already fall back
      to the bundled brand tile, so the app degrades cleanly - and the URL
      lives in exactly one place (`PresetService.logoUrl`), which is what made
      the Clearbit migration a one-line change.
- [ ] **Logos are favicons, not full brand marks.** Google returns roughly
      128px icons. Good enough at the sizes used here, but if crisper artwork
      is ever needed, a licensed logo API or bundled official assets would be
      the upgrade path.
- [ ] **Encryption at rest.** The old Hive setup was encrypted; the Drift
      database is not. Add `sqlcipher_flutter_libs` if subscription names and
      prices should be protected on a rooted device.
- [ ] **App bundle fails to strip debug symbols.** `flutter build apk` works,
      but `flutter build appbundle --release` errors out because the Android
      `cmdline-tools` component is missing (see `flutter doctor`). Install it
      from Android Studio before the first Play Store upload.
- [ ] **Privacy policy URL.** The onboarding notice explains data handling
      in-app, but Google Play also requires a hosted policy page before a
      listing goes live.
- [ ] **Delete the old project copy** at `C:\Masaüstü\subscriptionHunter-main`.
      It could not be removed automatically because this session's shell held
      the directory open.

## Nice to have

- [ ] Re-schedule reminders from a background worker so they survive months of
      the app not being opened (currently 3 charges are pre-scheduled per
      subscription).
- [ ] Archive/unarchive UI — the entity and database support `isArchived`, but
      nothing in the UI sets it yet.
- [ ] Edit an existing subscription's end date (`endDate` is stored and honoured
      by the billing engine, but the form does not expose it).
- [ ] Export to CSV / PDF.
- [ ] Let the user re-open the data notice from Settings after onboarding.
- [ ] Widen integration coverage: editing an existing subscription and the
      reminder time picker are not yet exercised.
- [ ] CI: run `flutter analyze` and `flutter test` on push.

## Done

### Latest round

- [x] **Replaced the dead logo provider.** `logo.clearbit.com` no longer has a
      DNS record - the free Logo API was retired - so every request failed and
      the app silently showed monogram tiles. Switched to Google's favicon
      service (PNG). DuckDuckGo's endpoint was rejected: it serves ICO, which
      Flutter cannot decode. Real brand logos now render on device.
- [x] **Fixed the form label collision.** Material floats a label into a notch
      cut in the field outline, which read as overlapping text on the filled,
      rounded fields. Labels now sit above their field.
- [x] **Removed estimated prices.** `suggestedPriceUsd` and its helper text
      are gone from the catalog, the form and all three ARB files - the
      figures were US-only and went stale.

### Previous round

- [x] **Add-subscription screen rebuilt.** Grouped into spaced, titled sections
      with larger fields; billing cycle moved from a dropdown to chips; save
      moved into a fixed bottom bar so it is reachable at any scroll position.
- [x] **Dynamic brand logos.** `cached_network_image` fetches from Clearbit
      with a shimmer placeholder, falling back to a brand-coloured initial
      avatar on any failure. Presets now store a `domain`, not a full URL.
- [x] **Onboarding flow.** Three intro panes plus a consent gate covering data
      use and notification permission. The app is unreachable until the data
      notice is accepted; state persists in `SharedPreferences` and the router
      redirects on it.
- [x] **Statistics diversified.** A segmented control switches between the
      category pie chart and the monthly-spend bar chart, plus a
      "most expensive" highlight card.
- [x] **Settings restructured.** Language and theme are now collapsible
      `ExpansionTile`s showing their current value in the header, and a
      "Contact & support" action opens the mail app to kodmod034@gmail.com
      with a fixed subject and pre-filled diagnostics.

### Earlier

- [x] Launcher icon and branded native splash screen.
- [x] Swipe-to-delete with an undo snackbar that restores the original row.
- [x] Explanatory empty state when a search matches nothing.
