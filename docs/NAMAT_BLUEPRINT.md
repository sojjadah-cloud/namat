# NAMAT — Product Blueprint

> Phase 1 deliverable: sitemap, user flows, user states, design tokens, component system,
> mobile screen structure. Everything below is implemented in the codebase.

---

## 1. SITEMAP

### Public (marketing) — sells the idea
```
/[locale]                     Landing (hero, trust, how it works, ecosystem,
                              personalization, app showcase, membership, community,
                              testimonials, partners, final CTA, footer)
/[locale]/about               Story, mission, Omani identity
/[locale]/services            Ecosystem detail, category deep-dive
/[locale]/partners            Partner wall + "Join NAMAT" for providers
/[locale]/packages            Public membership preview (pre-auth pricing)
```

### Auth — app-style, not a form
```
/[locale]/welcome             Language selection (العربية / English)
/[locale]/signup              Phone-first account creation
/[locale]/signup/verify       6-digit OTP
/[locale]/signup/name         "What should we call you?"
/[locale]/login               Returning user
/[locale]/onboarding          7-step personalization (one question per screen)
```

### Application — the product
```
/[locale]/app                 Home (personalized daily starting point)
/[locale]/app/search          Global search
/[locale]/app/explore         Discovery marketplace
/[locale]/app/explore/[slug]  Provider detail
/[locale]/app/book/[serviceId]  Booking flow (service → date → time → review → confirm)
/[locale]/app/bookings        Upcoming / Past / Cancelled
/[locale]/app/bookings/[id]   Booking detail (reschedule, cancel, directions)
/[locale]/app/journey         My Journey — member & non-member states
/[locale]/app/journey/package Package details, usage, pause/upgrade/cancel
/[locale]/app/packages        Package discovery
/[locale]/app/packages/[slug] Package detail + checkout
/[locale]/app/notifications   Notification centre
/[locale]/app/profile         Identity + settings hub
/[locale]/app/profile/goals   Goals editor → re-personalizes feed
/[locale]/app/profile/preferences  Interests, activity, times, dietary
/[locale]/app/profile/favorites    Saved providers & services
/[locale]/app/profile/language     Locale switch (persisted)
/[locale]/app/profile/payment      Payment methods
```

**Rule:** Packages are reachable from Home, Journey and Profile — but never a 6th bottom-nav item.

---

## 2. USER FLOWS

| Flow | Path |
|---|---|
| A | Landing → `Start Your Journey` → Welcome (language) → Signup |
| B | Signup → OTP → Name → Onboarding ×7 → Ready → Home |
| C | Home → Explore → Provider → Service → Date → Time → Review → Confirm → Success |
| D | Home → Search → Result → Provider |
| E | Journey (no package) → Packages → Package → Checkout → Success |
| F | Package purchase → Journey switches to member command-centre |
| G | Journey → Package Details → Pause (confirm sheet) → Paused state |
| H | Journey → Package Details → Change/Upgrade → Checkout |
| I | Bookings → Detail → Reschedule → new date/time → Confirmed |
| J | Bookings → Detail → Cancel (policy shown) → Cancelled tab |
| K | Profile → Goals/Preferences → Save → Home feed re-ranks |
| L | Any screen → language switch → full RTL/LTR flip, locale persisted |

---

## 3. USER STATES

**Identity:** guest · new signup · onboarding-incomplete · registered
**Membership:** none · active · paused · expired
**Booking:** upcoming · completed · cancelled · reschedule-pending
**Data:** loading (skeleton) · empty (with action) · error (with recovery) · no-results · location-denied

Every state has a designed screen. No blank whites, no dead ends.

---

## 4. DESIGN TOKENS

### Colour
| Token | Value | Use |
|---|---|---|
| `--namat-green` | `#4F6B57` | Primary actions, importance (10–15% of surface) |
| `--namat-green-deep` | `#3D5344` | Pressed, deep sections |
| `--namat-sage` | `#8DA78F` | Secondary accents |
| `--namat-canvas` | `#F6F8F4` | Page background (65–75%) |
| `--namat-surface` | `#FFFFFF` | Cards |
| `--namat-warm` | `#E9E4D9` | Warm surface (8–10%) |
| `--namat-accent` | `#D8B88C` | Premium accent (2–5%) |
| `--namat-ink` | `#17201A` | Primary text |
| `--namat-ink-soft` | `#667068` | Secondary text |

### Typography
Arabic **IBM Plex Sans Arabic** · Latin **Inter**. Two families, nothing else.

| Role | Desktop | Mobile |
|---|---|---|
| Marketing hero | 64–96px | 42–54px |
| Section heading | 48–68px | 32–40px |
| App page title | 24–32px | 24–28px |
| Card heading | 18–24px | 18–20px |
| Body | 15–18px | 15–16px |
| Label | 12–14px | 12–13px |

### Radius
`12 · 16 · 20 · 24 · 28 · 32` — editorial containers `40`. Nothing else.

### Elevation
`--shadow-sm: 0 6px 24px rgba(23,32,26,.04)`
`--shadow-md: 0 10px 35px rgba(23,32,26,.06)`
Hierarchy comes from spacing, type and surface — not shadow.

### Motion
200–350ms, `cubic-bezier(.22,.61,.36,1)`. Fade, small translate, soft scale, shared layout,
bottom-sheet spring, tab indicator. Honours `prefers-reduced-motion`.

### Breakpoints
`375 · 390 (primary) · 430 · 768 · 1024 · 1280 · 1440 · 1728`

---

## 5. COMPONENT SYSTEM

**Primitives** — Button, IconButton, Input, SearchField, OTPInput, Select, Checkbox, Radio,
Switch, Chip, Badge, Tabs, SegmentedControl, ProgressBar, Skeleton, Toast, Avatar, Rating.

**Surfaces** — Card, BottomSheet, Modal, EmptyState, ErrorState, SectionHeader, Carousel.

**Card families** (deliberately distinct, never interchangeable):
| Card | Job |
|---|---|
| `CategoryCard` | Photography-led visual discovery |
| `ProviderCard` | Provider identity, rating, distance, package inclusion |
| `ServiceCard` | One bookable service: duration, price or "Included" |
| `BookingCard` | Operational appointment info + status |
| `PackageCard` | Membership value + benefits |
| `JourneyCard` | Personal progress & allowance usage |
| `RecommendationCard` | Explainable suggestion ("because you…") |
| `ProductCard` | Healthy products |

**Navigation** — PublicNav (sticky, translucent-after-scroll), Footer, BottomNavigation (5 max),
AppHeader, BackBar.

---

## 6. MOBILE SCREEN STRUCTURE (390×844)

```
Home        Header(greeting+location+bell) · Search · NAMAT Today ·
            Upcoming booking* · Categories · Recommended · Active package* ·
            Near you · Try something new
Explore     Title · Search+Filter · Category chips · Quick filters · Result list
Provider    Gallery · Identity+rating+distance · Tags · About · Services ·
            Availability · Reviews · Location · Sticky Book bar
Journey     Non-member: goal, interests, two paths (book individually / package)
            Member: week, progress, today timeline, package summary, upcoming, next step
Bookings    Tabs(Upcoming/Past/Cancelled) · BookingCards
Profile     Identity · Personalization group · Account group · Logout
```

Bottom navigation (max 5): Home · Explore · My Journey · Bookings · Profile.

---

## 7. DESKTOP ADAPTATION
Not a stretched phone. Home → 3-column editorial grid. Explore → sidebar filters + card grid.
Provider → content column + sticky booking panel. Journey → consumer dashboard.
Profile → settings sidebar.
