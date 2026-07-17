# nef-list

Stupid list for friends. Anyone can drop their name, pfp, socials (discord, telegram, twitter/x, bluesky, steam friend code), and a message. No accounts. Dark mode only. Runs on Cloudflare Workers + D1.

## Features

- **No accounts** — posting hands your browser a secret edit token (kept in `localStorage`). That token is what lets you edit or delete your own entry later, from the same browser.
- **Share** — every entry gets a permalink (`/e/<id>`) with proper Open Graph / Twitter / oEmbed tags, so it embeds nicely in Discord, Telegram, X, etc.
- **Only one rule** — no links in name/message/handles. Everything else goes. The pfp field is the only URL allowed (https only).
- **Handles, not links** — social fields take usernames only. Pasting a full profile URL is fine; it gets stripped down to the handle. Telegram/X/Bluesky/Steam render as profile links (steam friend code converts to a SteamID64 profile URL); discord shows the username with click-to-copy.

## Deploy

```bash
bun install

# 1. create the database
bunx wrangler d1 create nef-list
# copy the printed database_id into wrangler.jsonc (replace REPLACE_WITH_DATABASE_ID)

# 2. create the table
bunx wrangler d1 migrations apply nef-list --remote

# 3. ship it
bunx wrangler deploy
```

Use bun. `npm install` can fail on some machines trying to compile `sharp` (an optional native dep of wrangler's dev server that this project never uses); if you must use npm, run `npm install --ignore-scripts`.

There is no build step — it's one plain-JS file and wrangler bundles it on deploy. `bun run build` exists only as a dry-run check (`wrangler deploy --dry-run`); real deploys are `bun run deploy`. If you hook the repo up to Cloudflare's git-connected Workers Builds instead, set the deploy command to `bunx wrangler deploy` and leave the build command empty.

First deploy prompts a browser login to your Cloudflare account. You get a `*.workers.dev` URL; add a custom domain later from the dashboard if you want.

## Local dev

```bash
bunx wrangler d1 migrations apply nef-list --local
bun run dev          # http://localhost:8787
```

Local mode uses a local SQLite file; the placeholder `database_id` is fine until you deploy.

## API

| Method | Path | Notes |
|---|---|---|
| `GET` | `/api/entries?cursor=` | newest first, 30/page |
| `POST` | `/api/entries` | returns `entry` + `edit_token` — save the token |
| `PATCH` | `/api/entries/:id` | header `x-edit-token` required |
| `DELETE` | `/api/entries/:id` | header `x-edit-token` required |
| `GET` | `/e/:id` | shareable entry page (OG/oEmbed embeds) |
| `GET` | `/api/oembed?id=` | oEmbed JSON for Discord and friends |

## Limits

name 40 · message 500 · discord 37 · telegram 32 · twitter 15 · bluesky 60 · steam code 10 digits · pfp URL 400 chars. Links rejected in all text fields.

## Moderation

If someone posts something dumb enough to remove (they're your friends, it'll happen):

```bash
bunx wrangler d1 execute nef-list --remote --command="DELETE FROM entries WHERE id='<id>'"
```
