# BUILD PLAN — Personal Money Tracker with On-Device Forecasting

Working name: **Baon**

This document is the implementation specification. Give it to Claude Code.
Written in ASD-STE100 Simplified Technical English.

---

## 1. PURPOSE

The app does five things:

1. It holds one balance for each money account. Examples: GCash, Maribank, GoTyme, cash.
2. It divides that money into envelopes. An envelope is a purpose, not a place.
   Examples: "Food and transport", "Dates", "Savings".
3. The user types the current balance. The app records the balance and the date.
4. The app computes a separate forecast for each envelope. It computes the probability of a
   shortfall in each envelope before that envelope refills.
5. The app explains the result in normal language.

**Accounts hold the money. Envelopes hold the purpose.** One GCash balance can carry parts of three
envelopes. Keep the two ideas separate in the code.

The app works offline. The forecast runs on the phone. The app sends no financial data to a server unless the user enables sync.

---

## 2. CRITICAL DESIGN RULE — READ FIRST

**The language model does not do arithmetic.**

A statistical engine computes every number. The engine is plain code. The engine is fully unit-tested.
The language model only converts a JSON result into a sentence.

Do not let the model calculate a runway, a balance, or a probability. A small on-device model makes
arithmetic errors. An arithmetic error in a money app destroys trust.

A runtime guard enforces this rule. See Section 9.4.

---

## 3. PRODUCT DECISIONS

| Topic | Decision | Reason |
|---|---|---|
| Data entry | Manual balance entry is the primary method | No public consumer API exists for GCash, Maribank, or GoTyme |
| Bank APIs | Out of scope for v1 | Aggregators such as Brankas need a business contract and a licence |
| Auto-capture | Android notification listener, optional, v2 | It reads transaction alerts. iOS does not permit this |
| Providers | Data-driven registry in a JSON file | New banks need no code change |
| Platform | Android first, then iOS | The Philippine market is mostly Android. Auto-capture is Android only |
| Budget model | Envelopes, not one pool | Different money has a different purpose and a different shape |
| Spend shape | Two models: steady and episodic | Daily food is steady. Dates are lumpy events |
| Fixed commute | A committed cost, not a random spend | A known weekday fare has no variance. Modelling it as random gives a false risk |
| Money type | 64-bit integer centavos | Floating point causes rounding errors |
| Source of truth | Local SQLite database | The app must work with no signal |
| Cloud | Optional sync only | Privacy first. Also lower cost |

---

## 4. NON-GOALS FOR v1

Do not build these:

- Bank login or screen scraping.
- Investment tracking.
- Bill payment.
- Multi-currency conversion. Use PHP only.
- Shared or family budgets.
- A chat interface with free conversation.

---

## 5. TECHNOLOGY STACK

**Chosen stack:**

| Layer | Choice |
|---|---|
| UI framework | Flutter (stable channel) |
| State | Riverpod |
| Local database | SQLite through Drift |
| Encryption at rest | SQLCipher through `sqlcipher_flutter_libs` |
| Key storage | `flutter_secure_storage` (Android Keystore, iOS Keychain) |
| Categorizer runtime | ONNX Runtime through `onnxruntime` Dart package |
| Language model runtime | llama.cpp through `fllama` (GGUF files) |
| Charts | `fl_chart` |
| Backend | Supabase (Postgres, Auth, Row Level Security) |
| Analytics | None in v1 |

**Alternative stack, if the developer prefers TypeScript:**
React Native with the New Architecture, plus `react-native-executorch` for on-device models.
This is a valid substitute. Do not mix the two stacks.

**Android-only fallback:**
If the developer drops iOS, use Kotlin with Jetpack Compose and the MediaPipe LLM Inference API.
This gives the best model performance. It also gives the simplest notification capture.

---

## 6. REPOSITORY LAYOUT

```
baon/
  lib/
    main.dart
    core/
      money.dart              # Money value type, centavos
      result.dart
      clock.dart              # Injectable clock. Never call DateTime.now() elsewhere
    data/
      db/                     # Drift tables, DAOs, migrations
      models/
      repositories/
      providers/registry.dart # Loads assets/providers.json
    engine/                   # PURE DART. NO UI. NO I/O.
      burn_rate.dart
      reconciler.dart
      forecast.dart
      monte_carlo.dart
      affordability.dart
      envelope.dart
    ai/
      categorizer/            # ONNX classifier
      explainer/              # GGUF small language model
      number_guard.dart
      templates.dart          # Fallback strings
    sync/
    features/
      onboarding/ accounts/ balance_entry/ dashboard/
      forecast_view/ transactions/ settings/
    ui/                       # Design tokens, shared widgets
  assets/
    providers.json
    models/                   # Downloaded at runtime, not committed
  test/
    engine/                   # Highest test priority
  integration_test/
  supabase/
    migrations/
  CLAUDE.md
```

**Rule:** `lib/engine/` must not import Flutter, Drift, or any plugin. It takes plain Dart objects
and returns plain Dart objects. This keeps it fast to test.

---

## 7. DATA MODEL

All money columns are `INTEGER`. All money columns hold centavos. All timestamps are UTC ISO-8601.

```sql
-- Static registry, seeded from assets/providers.json
provider(
  key TEXT PRIMARY KEY,        -- 'gcash', 'maribank', 'gotyme', 'seabank', 'maya', 'bpi', 'cash'
  display_name TEXT,
  kind TEXT,                   -- 'ewallet' | 'digital_bank' | 'traditional_bank' | 'cash'
  brand_color TEXT,
  logo_asset TEXT,
  notification_package TEXT    -- Android package name, nullable
)

account(
  id TEXT PRIMARY KEY,
  user_id TEXT,
  provider_key TEXT,
  label TEXT,                  -- 'GCash main'
  role TEXT,                   -- 'spending' | 'savings' | 'buffer'
  include_in_spendable INTEGER,-- 0 or 1
  is_archived INTEGER,
  created_at TEXT,
  updated_at TEXT
)

balance_snapshot(
  id TEXT PRIMARY KEY,
  account_id TEXT,
  balance_cents INTEGER,
  source TEXT,                 -- 'manual' | 'notification' | 'derived'
  captured_at TEXT,
  note TEXT
)

txn(
  id TEXT PRIMARY KEY,
  account_id TEXT,
  amount_cents INTEGER,        -- always positive
  direction TEXT,              -- 'in' | 'out'
  category_key TEXT,
  merchant_raw TEXT,           -- source text for the categorizer
  note TEXT,
  occurred_at TEXT,
  source TEXT,                 -- 'manual' | 'notification' | 'reconciled'
  category_confidence REAL,
  user_corrected INTEGER,      -- 1 marks a training label
  updated_at TEXT
)

category(
  key TEXT PRIMARY KEY,
  display_name TEXT,
  is_essential INTEGER,        -- transport and food are essential. Dates are not
  icon TEXT,
  sort_order INTEGER
)

obligation(                    -- known future outflows
  id TEXT PRIMARY KEY,
  user_id TEXT,
  label TEXT,                  -- 'Load', 'Rent share', 'Netflix'
  amount_cents INTEGER,
  cadence TEXT,                -- 'once' | 'weekly' | 'monthly'
  next_due_on TEXT,
  category_key TEXT
)

income_expectation(            -- allowance or stipend
  id TEXT PRIMARY KEY,
  user_id TEXT,
  label TEXT,
  amount_cents INTEGER,
  cadence TEXT,
  next_expected_on TEXT,
  confidence TEXT              -- 'certain' | 'likely' | 'unsure'
)

envelope(
  id TEXT PRIMARY KEY,
  user_id TEXT,
  label TEXT,                  -- 'Food and transport', 'Dates', 'Savings'
  shape TEXT,                  -- 'steady' | 'episodic' | 'reserve'
  refill_cents INTEGER,        -- 200000 for a 2000 PHP weekly budget
  refill_cadence TEXT,         -- 'weekly' | 'monthly' | 'none'
  refill_anchor TEXT,          -- weekday name or day of month
  allow_borrow_from TEXT,      -- JSON list of envelope ids, or empty
  priority INTEGER,            -- 1 is protected first
  sort_order INTEGER
)

envelope_category(             -- routes a transaction to an envelope
  envelope_id TEXT,
  category_key TEXT,
  PRIMARY KEY (envelope_id, category_key)
)

allocation(                    -- current money in each envelope
  id TEXT PRIMARY KEY,
  envelope_id TEXT,
  balance_cents INTEGER,
  period_start TEXT,
  updated_at TEXT
)

borrow_event(                  -- one envelope covers another
  id TEXT PRIMARY KEY,
  from_envelope_id TEXT,
  to_envelope_id TEXT,
  amount_cents INTEGER,
  occurred_at TEXT,
  repaid_at TEXT               -- nullable
)

setting(key TEXT PRIMARY KEY, value TEXT)
```

**Seed categories:** `transport`, `food_daily`, `food_delivery`, `groceries`, `dates_leisure`,
`load_data`, `school`, `health`, `shopping`, `fees`, `transfer_internal`, `savings_in`,
`income`, `other`.

Mark `transport`, `food_daily`, `school`, `health`, and `load_data` as essential.

---

## 8. THE ENGINE — CORE SPECIFICATION

Build this module first. Build it with tests before the UI.

### 8.1 Reconciliation

The user will not log every jeepney fare. The app must still know the spend rate.
Therefore the app derives spend from the change in balance.

When the user saves a new snapshot for an account:

```
last       = most recent previous snapshot for that account
logged     = sum of signed txn amounts between last.captured_at and new.captured_at
expected   = last.balance_cents + logged
delta      = new.balance_cents - expected

IF delta < -TOLERANCE:
    create txn(direction='out', amount=|delta|, category_key='other',
               source='reconciled', occurred_at=midpoint(last, new))
IF delta > TOLERANCE:
    create txn(direction='in', amount=delta, category_key='other',
               source='reconciled', occurred_at=midpoint(last, new))
```

Set `TOLERANCE` to 100 centavos.

Show the derived item in the UI as "Unaccounted". Let the user split it or label it later.
Each label the user gives becomes a training row. See the training plan.

### 8.2 Balance and envelope aggregates

```
account_total_cents = SUM(latest snapshot for every active account)
envelope_total_cents = SUM(allocation.balance_cents)
unallocated_cents = account_total_cents - envelope_total_cents
```

**Invariant:** `unallocated_cents` must never be negative. If it is negative, the user has spent money
that no envelope covers. Show a "Fix your envelopes" card. Do not hide the error.

Every envelope has its own forecast. Never add the envelopes together to make one runway number.
A shortfall in "Dates" is a different problem from a shortfall in "Food and transport".

Mark a snapshot as stale after 72 hours. Show a "Refresh balances" prompt when a snapshot is stale.
Do not forecast on stale data without a warning.

### 8.3 Horizon

```
horizon_end = earliest next_expected_on among income_expectation rows
              ELSE the user-set date
              ELSE today + 14 days
days_left   = number of whole days from today to horizon_end
```

### 8.4 Burn-rate estimators — one method for each envelope shape

Exclude `transfer_internal` and `savings_in` from outflow. A transfer is not a spend.

**Shape `steady`.** Use this for food and transport. The user spends a small amount most days.

Compute daily outflow totals over a lookback window. Default window is 28 days. Minimum is 7 days.

1. **Mean.** `sum(outflow) / window_days`.
2. **EWMA.** Apply `s(t) = a * x(t) + (1 - a) * s(t-1)` with `a = 0.35`. Use the final value.
3. **Day-of-week pool.** For each weekday, keep the list of daily outflow totals.

The day-of-week pool matters. A weekday costs more than a weekend when the user commutes to an
office five days a week. A flat average hides that gap.

**Shape `episodic`.** Use this for dates and for any lumpy spend. A daily average is wrong here.
A user does not spend 143 PHP a day on dates. The user spends 1,000 PHP twice a month and nothing
on the other days.

Model the envelope as two separate variables:

```
event_rate  = number of events in the window / number of weeks in the window
event_sizes = list of amounts, one for each event
```

Estimate the rate with a Poisson mean. Resample the size from the empirical list.
Report both parts to the user. "About 2 dates a week, about PHP 900 each" is more useful than
"PHP 257 a day".

**Shape `reserve`.** Savings. No burn model. Track the balance only. Never include it in a runway.

**Committed costs.** A known fixed cost is not a random spend. If the user declares a weekday
commute of 150 PHP, subtract `150 * remaining_weekdays` as a committed amount. Do not put it in the
random pool. This removes variance and makes the forecast much sharper.

Prompt the user for the commute cost during onboarding. It is usually the largest fixed item.

### 8.5 Deterministic runway, per envelope

Run this for each envelope. `horizon_end` is that envelope's next refill date.

```
committed  = SUM(obligations mapped to this envelope, due on or before horizon_end)
usable     = allocation.balance_cents - committed - safety_floor
runway_days = usable / max(daily_burn, 1)          # steady envelopes only
safe_daily  = usable / max(days_left, 1)           # steady envelopes only
events_left = usable / median(event_sizes)         # episodic envelopes only
```

For an episodic envelope, report **events left**, not days left.
"You can afford 1 more date this week" is the answer the user wants.

Default `safety_floor` to 20000 centavos (200 PHP) on the steady envelope, and 0 on the others.

### 8.6 Monte Carlo simulation

This produces the probability, not the language model. Run one simulation for each envelope, then
one combined run that models spill.

```
runs = 2000
seed = hash(user_id + envelope_id + today)   # same input gives the same answer on the same day

for each run:
    balance = allocation.balance_cents
    min_balance = balance
    for each day d from today to horizon_end:

        IF shape == 'steady':
            pool = dow_pool[weekday(d)]
            if length(pool) < 3: pool = global_pool
            spend = random choice from pool

        IF shape == 'episodic':
            n = Poisson(event_rate / 7)          # events on this one day
            spend = sum of n draws from event_sizes

        balance -= spend
        balance -= committed costs due on d
        balance += refill on d, only if confidence = 'certain'
        min_balance = min(min_balance, balance)

    record end_balance and min_balance

p_shortfall = count(min_balance < safety_floor) / runs
p10, p50, p90 = percentiles of end_balance
```

**Spill rule.** After the per-envelope runs, run a combined pass. When an episodic envelope goes
below zero on a day, and `allow_borrow_from` names the steady envelope, move the deficit across.
Then re-measure the steady envelope.

Report two separate numbers:

- `p_shortfall_own` — the risk inside the envelope itself.
- `p_shortfall_with_spill` — the risk to food and transport caused by the dates envelope.

The second number is the one that matters. A date overrun is only a real problem when it eats the
food budget. Show the link plainly: "A third date this week takes PHP 400 from food."

Cap the runtime at 80 ms on a mid-range phone for all envelopes together. Cache the result.
Invalidate the cache on any new snapshot, transaction, obligation, or borrow event.

### 8.7 Affordability check

This answers the real question: "Can I afford a 1000 PHP date on Saturday?"

The user picks the envelope. The default envelope comes from the category.

```
base = simulate_all()
test = simulate_all with an extra outflow of X on date D in envelope E

delta_own   = test.E.p_shortfall_own   - base.E.p_shortfall_own
delta_spill = test.steady.p_shortfall_with_spill
              - base.steady.p_shortfall_with_spill

verdict = worst of the two:
  'safe'  if both risks are under 0.10
  'tight' if both risks are under 0.35
  'risky' otherwise
```

Return three things:

1. The money left in that envelope after the event.
2. The change in the food and transport risk, in peso terms, not only in percent.
3. The number of further events the envelope still supports.

Example output: "Yes, but it leaves PHP 200 in Dates for 5 days. It does not touch food."
This turns a vague worry into a number.

### 8.8 Engine output contract

The engine returns exactly this object. The AI layer receives only this object.

```json
{
  "as_of": "2026-09-04",
  "currency": "PHP",
  "account_total": 684000,
  "unallocated": 0,
  "envelopes": [
    {
      "id": "env_food",
      "label": "Food and transport",
      "shape": "steady",
      "balance": 92000,
      "refill_cents": 200000,
      "days_left": 3,
      "committed": 45000,
      "committed_note": "commute, 3 weekdays at PHP 150",
      "daily_burn_ewma": 21000,
      "daily_burn_median": 19000,
      "safe_daily": 15600,
      "runway_days": 4.4,
      "p_shortfall_own": 0.22,
      "p_shortfall_with_spill": 0.38,
      "end_balance_p10": -8000,
      "end_balance_p50": 14000,
      "end_balance_p90": 33000
    },
    {
      "id": "env_dates",
      "label": "Dates",
      "shape": "episodic",
      "balance": 120000,
      "refill_cents": 300000,
      "days_left": 12,
      "event_rate_per_week": 1.8,
      "event_size_median": 90000,
      "events_affordable": 1,
      "p_shortfall_own": 0.47,
      "borrow_target": "env_food",
      "expected_spill": 26000
    },
    {
      "id": "env_savings",
      "label": "Savings",
      "shape": "reserve",
      "balance": 472000
    }
  ],
  "largest_lever": {
    "envelope_id": "env_dates",
    "action": "one fewer event this period",
    "saving": 90000,
    "food_risk_after": 0.14
  },
  "stale_accounts": [],
  "data_quality": "good"
}
```

Set `data_quality` to `low` when the history is under 7 days. When quality is low, the UI must show
a range, not a single number. It must also say that the estimate improves with more data.

---

## 9. THE AI LAYER

### 9.1 Three tiers

| Tier | Function | Technology | Ship in |
|---|---|---|---|
| 0 | All numbers | The engine in Section 8 | v1 |
| 1 | Category from merchant text | Small ONNX classifier | v1 |
| 2 | Plain-language explanation | Small language model, GGUF | v2 |

Ship Tier 0 and Tier 1 first. Tier 2 needs training data that does not yet exist.

### 9.2 Tier 1 — Categorizer

- Input: `merchant_raw` plus the amount bucket plus the hour of day.
- Output: a category key and a confidence value.
- v1 model: character n-gram TF-IDF plus logistic regression, exported to ONNX. Size under 2 MB.
- Rule layer runs first. A keyword table catches obvious cases. Examples: "GRABPAY", "JEEP", "7-ELEVEN".
- Auto-apply the category only when confidence is above 0.85. Otherwise ask the user.
- Store every user correction with `user_corrected = 1`. These rows are the training set.

Ship a rule-only version if the model is not ready. The app must not block on the model.

### 9.3 Tier 2 — Explainer

- Model: Gemma 3 270M Instruct, INT4 quantized, GGUF format. It is small and battery efficient.
- Runtime: `fllama` on Flutter, or the MediaPipe LLM Inference API on native Android.
- Download the model on first use. Do not put it in the APK. Let the user delete it.
- Context: the JSON object from Section 8.8, plus a fixed instruction, plus the user question.
- Output limit: 90 tokens. Temperature 0.3.

The system prompt must state the rule clearly:

```
You explain a money forecast. All numbers are given to you in the JSON.
Copy numbers exactly from the JSON. Never calculate a new number.
Answer in 2 to 4 short sentences. Be direct. Do not moralize.
```

### 9.4 Number guard — mandatory

After generation, run this check:

1. Extract every number from the model output with a regular expression.
2. Normalise each number. Remove commas. Convert to centavos.
3. Compare each number against the set of values in the input JSON, and against simple derived forms
   (percentages of the probability field, pesos from centavos).
4. If any number is not in the allowed set, discard the whole output.
5. Fall back to a template string built by the engine.

Log every rejection. The rejection rate is a model quality metric.

### 9.5 Template fallback

The app must be fully useful with the model turned off. Write templates for every state.

Example:
`"You have PHP {spendable} for {days_left} days. That is PHP {safe_daily} a day.
You currently spend about PHP {daily_burn_ewma} a day. Chance of running short: {p_shortfall}%."`

---

## 10. AUTO-CAPTURE (v2, ANDROID ONLY)

- Use `NotificationListenerService` through a Flutter platform channel.
- Filter by the package names in `providers.json`.
- Parse the notification text with per-provider regular expressions in a versioned JSON file.
- Never store the raw notification body after parsing. Store only the amount, the merchant, and the time.
- The feature is opt-in. Show a clear screen that explains what the app reads.
- Google Play requires a prominent disclosure for this permission. Write the disclosure before release.
- Do not use SMS reading. The Play Store SMS policy is strict and the review often fails.

---

## 11. ACCOUNTS AND SYNC

- Auth: Supabase email and password, plus optional Google sign-in.
- The local database is the source of truth. The app must work with no account.
- Ask for an account only when the user taps "Back up my data".
- Sync model: outbox queue, per-row `updated_at`, last-write-wins, soft delete with `deleted_at`.
- Enable Row Level Security on every table. Policy: `auth.uid() = user_id`.
- Sync balances and transactions. Do not sync the model files.

---

## 12. SECURITY

- Encrypt the SQLite file with SQLCipher. Store the key in the platform keystore.
- Add an app lock. Use biometrics with a PIN fallback.
- Never write balances to logs. Add a lint rule.
- Set `FLAG_SECURE` on Android to block screenshots on the dashboard.
- Add a "Delete all my data" button. It must delete the local file and the server rows.
- Write a short privacy policy before the Play Store listing.

---

## 13. SCREENS

1. **Onboarding.** Pick providers. Enter the first balance for each. Then build the envelopes:
   the name, the refill amount, the refill day, and the shape. Ask for the weekday commute cost.
2. **Dashboard.** One card for each envelope. Never one combined number.
   - Steady card: money left, days left, safe daily amount, risk badge.
   - Episodic card: money left, events still affordable, risk badge.
   - Reserve card: balance only.
   Show a spill warning bar when one envelope threatens another.
3. **Update balances.** A single list. One number field per account. This is the main daily action.
   Keep it under 15 seconds. Route any unaccounted change to an envelope with one tap.
4. **Forecast.** Pick an envelope. Show a fan chart from P10 to P90 and the shortfall probability.
   For an episodic envelope, show the event rate and the event size instead of a daily rate.
5. **Can I afford this?** Amount, date, and envelope. Show the verdict, the money left in that
   envelope, and the effect on food and transport in pesos.
6. **Transactions.** A list. "Unaccounted" items are at the top and need a label.
7. **Settings.** Safety floor, model download, lock, export to CSV, delete data.

Design guidance: one primary number per screen. Use colour for state, not for decoration.
Never show a red screen without a next action.

---

## 14. MILESTONES

Each milestone must build, pass tests, and run on a device.

| ID | Goal | Done when |
|---|---|---|
| M0 | Project skeleton, CI, lint, `Money` type | `flutter test` passes. Money math has 100% branch coverage |
| M1 | Database, provider registry, account CRUD, envelope CRUD | The user can add 3 accounts and 3 envelopes. The unallocated invariant holds |
| M2 | Balance entry, reconciliation, envelope routing | A snapshot change creates a correct "Unaccounted" transaction and lands in one envelope |
| M3 | Engine: steady burn rate, committed commute, runway | Golden tests pass on 5 fixed scenarios |
| M3b | Engine: episodic model, event rate and size | Event counts and sizes are correct on a fixture with 8 lumpy events |
| M4 | Engine: Monte Carlo, spill, affordability | The simulation is deterministic for a fixed seed. Runtime is under 80 ms for all envelopes |
| M5 | Dashboard and forecast screens | The full loop works offline on a real phone |
| M6 | Rule-based categorizer and category UI | Correction flow stores labels |
| M7 | Auth and sync | Sign in on a second device restores the data |
| M8 | ONNX categorizer | Macro-F1 is at or above 0.80 on the held-out set |
| M9 | Explainer model plus number guard | Number-guard rejection rate is under 2% on 200 fixtures |
| M10 | Android notification capture | Opt-in flow, disclosure screen, parser tests |
| M11 | Play Store internal test release | Signed build, privacy policy, store listing |

---

## 15. TEST PLAN

- **Engine unit tests are the priority.** Target 90% line coverage in `lib/engine/`.
- Build a fixture set of at least 12 scenarios. Include these edge cases:
  - Zero history.
  - One day of history.
  - A negative balance.
  - A large one-off income.
  - A weekend spike pattern.
  - A stale snapshot.
- Property test: the sum of reconciled deltas plus logged transactions must equal the balance change.
- Golden test the engine JSON output. A change to the schema must fail the test.
- Widget tests for the balance entry form.
- One integration test for the whole offline loop.

---

## 16. CLAUDE.md FOR THE REPOSITORY

Put this file at the repository root.

```markdown
# Baon — Agent Instructions

## Rules
- Money is `int` centavos. Never use `double` for money.
- `lib/engine/` is pure Dart. It must not import Flutter or any plugin.
- Never call `DateTime.now()` outside `core/clock.dart`. Inject the clock.
- The language model never computes a number. See BUILD_PLAN.md Section 2.
- Write the test before the engine function.
- Do not add a package without a note in the pull request that explains why.

## Commands
- Test: `flutter test`
- Analyse: `flutter analyze`
- Format: `dart format .`
- Run: `flutter run`

## Definition of done
1. `flutter analyze` reports zero issues.
2. `flutter test` passes.
3. New engine logic has a test.
4. No balance value appears in any log statement.

## Order of work
Follow the milestones M0 to M11 in BUILD_PLAN.md. Do not skip ahead.
Stop and ask before you change the engine output schema in Section 8.8.
```

---

## 17. DEPLOYMENT

1. Create the Supabase project. Apply the migrations. Turn on Row Level Security.
2. Create the Google Play developer account. The fee is a one-time 25 USD.
3. Build a signed release bundle. Use Play App Signing.
4. Publish to the internal test track first. Add 5 testers.
5. Write the data safety form. Declare local storage and optional cloud sync.
6. Move to closed test, then to production.
7. For iOS, an Apple Developer account costs 99 USD each year. Delay this until the app has users.

Host the model file on Hugging Face or on Supabase Storage. Verify the SHA-256 hash after download.

---

## 18. RISK LIST

| Risk | Effect | Action |
|---|---|---|
| The user stops updating balances | The forecast decays | Send one daily reminder. Keep entry under 15 seconds |
| Too little history in week 1 | A wrong probability | Show a range. Set `data_quality: low`. Widen the interval |
| The model gives a wrong number | Loss of trust | The number guard in Section 9.4 |
| The model file is too large | Users uninstall | Make it an optional download. Show the size first |
| Notification parsing breaks | Silent data loss | Version the parsers. Compare against the reconciler |
| Play Store rejects the listener | Feature loss | The app must be fully useful without it |
