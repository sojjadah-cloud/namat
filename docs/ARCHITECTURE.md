# NAMAT Architecture Documentation

## Frontend Architecture
* **Framework**: Next.js (App Router)
* **UI Library**: React, Tailwind CSS, shadcn/ui.
* **Language**: Strict TypeScript.
* **Rendering**: Server Components where appropriate, Client Components only when interaction is required.

## Backend Architecture
* **API Layer**: Next.js Route Handlers / Server Actions.
* **Database**: PostgreSQL.
* **ORM**: Prisma.
* **Authentication**: NextAuth.js (or similar) with server-side role verification.

## Database Core Schema (Conceptual)
* `User`, `Role`, `Session`, `Account`
* `Journey`, `Goal`, `Task`, `Progress`
* `Specialist`, `Booking`, `AvailabilitySlot`
* `Restaurant`, `Meal`, `FoodOrder`
* `SportVenue`, `Class`, `SportBooking`
* `Vendor`, `Product`, `ShopOrder`
* `Challenge`, `ChallengeParticipant`
* `Package`, `UserPackage`

## Authorization & Security
* Server-side authorization for all sensitive actions.
* Input validation (e.g., using Zod).
* Granular privacy controls for wellness data.
* Never expose secrets to client bundles.

## Marketplace Architecture
* Abstractions for Cart (supporting meals and shop items).
* Abstractions for Payments, supporting partial refunds, partner payouts, and platform commissions.
* Unified search interface.

## Scaling Considerations
* Pagination and infinite loading for large lists.
* Optimized database queries and appropriate indexing.
* Preparation for future modules (Wearables integration, Corporate Wellness).
