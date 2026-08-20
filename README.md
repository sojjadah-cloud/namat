# NAMAT

> **Your Healthy Lifestyle**

NAMAT is a premium digital health and wellness lifestyle ecosystem.

## 0. Project Overview
This repository contains the source code for the NAMAT platform. It integrates:
* Professional consultations
* Healthy meals
* Sports and fitness activities
* Gyms and facilities
* Wellness products
* Health-related products
* Challenges
* Social challenges
* Personalized wellness packages
* User progress

## 1. Development Requirements
* Node.js (v18+)
* PostgreSQL
* npm or yarn

## 2. Installation
```bash
npm install
```

## 3. Environment Setup
Copy the `.env.example` file to `.env.local` and populate the values.
```bash
cp .env.example .env.local
```

## 4. Database Setup
```bash
npx prisma generate
npx prisma db push
```

## 5. Running the Application
```bash
npm run dev
```

## 6. Testing
```bash
npm run test
```

## 7. Documentation
Refer to the `docs/` directory for detailed documentation:
* `docs/PRODUCT.md` - Product overview, personas, modules, journeys.
* `docs/DESIGN_SYSTEM.md` - Colors, typography, spacing, components.
* `docs/ARCHITECTURE.md` - Frontend/Backend architecture, database, APIs.
