# Product

<!-- impeccable:product-schema 1 -->

## Platform

android

Flutter. Android first, then iOS. During development it is verified on
Windows desktop (`flutter run -d windows`) because this machine has no Android
SDK.

## Users

Filipino students living on baon: a weekly or monthly allowance from family,
spread across GCash, Maribank, GoTyme and cash. They check and update balances
during the day, on the go: on a jeepney or the MRT, or in line at a store, in
bright light, often one-handed.

## Product Purpose

Baon holds one balance per money account and divides that money into
envelopes (purposes, not places: "Food and transport", "Dates", "Savings"). The
student types the current balance; the app records it, forecasts each envelope
on-device, and says in plain language how likely each envelope is to run short
before it refills. Success means the student knows, in seconds, whether this
week's baon will last.

## Positioning

Forecasts per envelope, not one pooled number, computed by a tested
statistical engine on the phone. A language model only phrases the result and
never computes a number. Works offline; no financial data leaves the phone
unless sync is turned on.

## Operating Context

- Main daily action: update balances, under 15 seconds.
- Screens: Onboarding, Dashboard (one card per envelope), Update balances,
  Forecast (P10–P90 fan chart), Can I afford this?, Transactions, Settings.
- Envelope shapes: steady (daily food and transport), episodic (dates,
  lumpy events), reserve (savings, balance only).
- Currency: PHP only, shown as "PHP".

## Capabilities and Constraints

- Money is integer centavos. The engine is pure Dart and fully unit-tested.
- One primary number per screen. Colour carries state (safe / tight / risky),
  not decoration. Never show a red state without a next action.
- No balance in any log. Dashboard is screenshot-blocked on Android.
- Non-goals for v1: bank login, investments, bill payment, multi-currency,
  shared budgets, free-form chat.

## Brand Commitments

- Name: Baon.
- Visual style is pinned by the user: glassmorphism.
- Must not feel like a bank app: not corporate, not cold, not navy-and-grey
  fintech.

## Evidence on Hand

- Provider list: `assets/providers.json`. Categorizer rules:
  `assets/categorizer_rules.json`.
- No logo, illustrations, testimonials or user data exist. Do not invent them.

## Product Principles

1. The forecast is the product: every screen leads with one honest number.
2. Trust comes from correctness: no number is ever produced by a model.
3. Fast on the go: the balance update finishes in seconds, in daylight, one-handed.
4. Private by default: offline-first, nothing leaves the phone without consent.
5. Every warning comes with a next action.
