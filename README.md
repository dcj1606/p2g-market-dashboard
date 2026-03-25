# Parcel2Go — UK Retail & Parcel Market Dashboard

Live board dashboard. Auto-refreshes every 30 minutes from a Google Sheet.

---

## 1 — First-time Google Sheets setup (one-off, ~10 minutes)

### Step 1: Create the spreadsheet

1. Go to [sheets.google.com](https://sheets.google.com) and create a new blank spreadsheet.
2. Name it **"P2G Market Dashboard Data"**.

### Step 2: Create the `monthly` sheet

1. Rename **Sheet1** to `monthly` (double-click the tab).
2. Add these exact column headers in **Row 1**:

   | A | B | C | D | E | F |
   |---|---|---|---|---|---|
   | `month_label` | `retail_mom` | `online_mom` | `online_pct` | `gfk_conf` | `retail_yoy` |

3. Paste in the historical data starting from **Row 2** (one row per month, oldest first):

   | month_label | retail_mom | online_mom | online_pct | gfk_conf | retail_yoy |
   |---|---|---|---|---|---|
   | Feb 25 | 1.0 | 1.0 | 26.7 | -20 | 2.5 |
   | Mar 25 | 0.1 | -0.3 | 27.0 | -19 | 2.3 |
   | Apr 25 | 1.2 | 0.8 | 26.8 | -23 | 4.5 |
   | May 25 | -2.8 | -1.5 | 27.4 | -17 | 1.7 |
   | Jun 25 | 0.9 | 2.3 | 27.8 | -20 | 1.8 |
   | Jul 25 | 0.6 | 2.0 | 27.7 | -22 | 1.1 |
   | Aug 25 | 0.5 | 0.4 | 27.6 | -13 | 0.7 |
   | Sep 25 | 0.3 | 0.8 | 27.7 | -20 | 3.9 |
   | Oct 25 | -0.9 | -1.2 | 28.4 | -21 | 2.4 |
   | Nov 25 | -0.1 | 0.7 | 28.6 | -19 | 0.6 |
   | Dec 25 | 0.4 | 1.8 | 28.3 | -17 | 2.5 |
   | Jan 26 | 1.8 | 3.4 | 28.2 | -16 | 4.5 |
   | Feb 26 | -1.2 | -0.8 |  | -19 | 1.1 |

   > **Note:** Leave `online_pct` empty for the latest month if ONS hasn't confirmed it yet.

### Step 3: Create the `snapshot` sheet

1. Click **+** at the bottom to add a new sheet. Name it `snapshot`.
2. Add these exact column headers in **Row 1**:

   | A | B | C | D | E |
   |---|---|---|---|---|
   | `metric_key` | `display_value` | `sub_text` | `color_class` | `label` |

3. Add 4 rows of data:

   | metric_key | display_value | sub_text | color_class | label |
   |---|---|---|---|---|
   | retail_mom | −1.2% | Sharp drop · poor weather cited | red | Retail sales MoM (Feb 2026) |
   | retail_yoy | +1.1% | Below consensus of +2.1% | amber | Retail sales YoY (Feb 2026) |
   | gfk | −19 | Down 3pts from Jan · rising unemployment | red | GfK Consumer Confidence (Feb) |
   | online_pct | 28.2% | vs 26.7% a year earlier ↑ | blue | Online share of retail (Jan 26) |

   > `color_class` must be one of: `red`, `amber`, `green`, `blue`, `neutral`

### Step 4: Share the spreadsheet

1. Click **Share** (top right).
2. Under **General access**, choose **"Anyone with the link"** → **Viewer**.
3. Click **Done**.

### Step 5: Copy the Sheet ID

The Sheet ID is the long string in the URL:
```
https://docs.google.com/spreadsheets/d/  ← SHEET_ID →  /edit
```
Example: `1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgVE2upms`

### Step 6: Update `index.html`

Open `index.html` and find:
```javascript
SHEET_ID: '1EWminnPJhrh1fVGMjznTz-7kqiy8gqLgUBCd03WuhCA',
```
Replace the placeholder with your actual Sheet ID:
```javascript
SHEET_ID: '1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgVE2upms',
```

Commit and push — Vercel will auto-deploy within ~30 seconds.

---

## 2 — Adding a new month's data (every month, ~5 minutes)

1. Open your Google Sheet → **`monthly`** tab.
2. **Add a new row** at the bottom with the new month's data:
   - `month_label` → e.g. `Mar 26`
   - `retail_mom` → ONS Retail Sales Index MoM % (e.g. `0.4`)
   - `online_mom` → ONS internet sales MoM % (e.g. `1.2`)
   - `online_pct` → ONS online share % (e.g. `28.5`) — leave **blank** until confirmed by ONS
   - `gfk_conf` → GfK consumer confidence index (e.g. `-21`)
   - `retail_yoy` → ONS retail YoY % (e.g. `2.1`)
3. **Delete the oldest row** (Row 2) to keep exactly 13 months visible.
4. Open the **`snapshot`** tab and update all 4 rows to reflect the new month's headline numbers.
5. That's it — the live dashboard will pick up the changes on its next auto-refresh (within 30 min), or immediately on page reload.

> **Tip:** The dashboard always shows the last N rows of the `monthly` sheet as its window. You can keep more than 13 rows and the charts will grow — but 13 is the recommended board-presentation window.

---

## 3 — Changing the refresh interval

In `index.html`, find:
```javascript
REFRESH_INTERVAL_MS: 30 * 60 * 1000,  // 30 minutes
```
Change `30` to any number of minutes you prefer. Commit and push.

---

## 4 — Repo structure

```
index.html      ← The full dashboard (single file)
vercel.json     ← Vercel deployment config
README.md       ← This file
```

---

## 5 — Data sources

| Series | Source | Frequency |
|---|---|---|
| Retail MoM & YoY % | ONS Retail Sales Index | Monthly (~4 weeks after month end) |
| Online % of retail | ONS RSI internet dataset | Monthly (same release) |
| GfK Consumer Confidence | GfK/NIQ press releases | Monthly (last Friday of each month) |
| SME indicators | FSB / KPMG / CPA (static) | Quarterly — update manually |
| Carrier landscape | Ofcom / CEP-Research (static) | Annual — update manually |
