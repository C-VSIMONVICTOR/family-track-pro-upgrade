# FamilyTrack Pro — GitHub Pages + Supabase

This repository is a static web app that can be tested on GitHub Pages. Supabase provides authentication, family membership, persistent location history, and realtime updates.

## GitHub Pages setup

1. Create a GitHub repository and upload the contents of this folder to the repository root.
2. Open `config.js` and replace the two placeholders with your Supabase project URL and **public anon key**.
3. In Supabase SQL Editor, run `supabase-schema.sql`.
4. Create at least one row in `families` with an `invite_code` that you will use to sign in.
5. In GitHub, open **Settings → Pages** and select **GitHub Actions** as the source.
6. Push to `main`; the workflow in `.github/workflows/pages.yml` deploys the site.

## Testing realtime

Open the deployed site in two browsers or phones. Sign in with two different accounts using the same family code. Start location sharing on one device and watch the other device's Family tab update. Trigger SOS on one device and confirm it appears in the other device's Alerts tab.

## Important security

- `config.js` contains only the public Supabase URL and anon key.
- Never commit a Supabase `service_role` key.
- Keep Row Level Security enabled and run the provided schema before testing.
- Real browser location requires HTTPS and explicit user permission.

## Realtime synchronization improvements

- Family members are keyed by their real Supabase `user_id`.
- The latest location is calculated per member instead of marking every member as live.
- Members become offline when their latest sharing update is older than two minutes.
- Location INSERT events update the correct member in realtime.
- New family-member INSERT events refresh the family list.
- SOS alerts continue to stream through Supabase Realtime.

## Android / Google Play

GitHub Pages is suitable for browser testing. For reliable background location while the app is locked or closed, the next step is an Android build using a native-capable wrapper such as Capacitor plus the required Android location permissions, foreground service behavior, privacy disclosures, and Play policy review.
