# LawHub - Legal Services Marketplace

LawHub is a full-stack legal services marketplace that connects clients with qualified lawyers. The ecosystem consists of a **Flutter mobile app**, a **Next.js admin portal**, and a **Help & Support admin dashboard**.

---

## Table of Contents

- [Overview](#overview)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Features](#features)
- [Getting Started](#getting-started)
- [Admin Portal (Web)](#admin-portal-web)
- [Help & Support Admin (Web)](#help--support-admin-web)
- [Firebase Setup](#firebase-setup)
- [Environment Variables](#environment-variables)

---

## Overview

LawHub is a two-sided platform:

- **Clients** can search for lawyers by expertise, location, or rating; hire them; chat and call in real-time; submit cases; and pay via Stripe.
- **Lawyers** can create profiles, get their licenses verified, accept client requests, manage cases, publish legal articles, and receive payments.
- **Admins** manage the platform through two separate web portals — one for lawyer approvals and user management, another for help & support ticket resolution.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile App | Flutter (Dart SDK >= 3.8.0) |
| Backend | Firebase (Auth, Firestore, Storage, Cloud Functions) |
| Payments | Stripe + Firebase Cloud Functions |
| Video/Voice Calls | Agora RTC Engine |
| AI Features | Grok AI, Deepgram STT |
| Image Hosting | Cloudinary |
| Admin Portal | Next.js 14, React 18, TypeScript, Firebase |
| Help & Support Portal | Vanilla HTML/CSS/JS, Firebase Web SDK v10 |

---

## Project Structure

### Mobile App (`LAWHUB/`)

```
lib/
├── main.dart                        # App entry point
├── AI_Pages/                        # AI chatbot & case research
├── Article_Pages/                   # Legal article management
├── Call_Pages/                      # Voice/video calls (Agora + Deepgram)
├── CaseDisplay_Pages/               # Case viewing & tracking
├── Chat_Pages/                      # Real-time messaging
├── Drawer_Pages/                    # Side menu, About Us, Terms, Help & Support
├── Firebase/                        # Firebase configuration
├── InformationUpdate_Pages/         # Profile & account updates
├── Lawyer_Pages/                    # Lawyer-specific screens
├── LoginSignup_Pages/               # Auth flows (login, signup, OTP, password reset)
├── Model/                           # Data models
├── Payment_Pages/                   # Stripe payments & wallet
├── Services/                        # Utility services
├── Starting_Pages/                  # Splash screen & onboarding
├── User_Pages/                      # Client-specific screens
├── Utils/                           # Helpers (toast, Cloudinary upload)
└── widgets/                         # Reusable UI components (buttons, fonts, themes)
```

### Admin Portal (`LAWHUB-Admin-Portal/`)

```
LAWHUB-Admin-Portal/
├── pages/
│   ├── index.js                     # Admin login page
│   ├── dashboard.js                 # Main dashboard
│   └── _app.js                      # App wrapper
├── styles/                          # CSS modules
├── firebase.config.js               # Firebase connection
└── package.json
```

### Help & Support Admin (`HelpSupportAdmin/`)

```
HelpSupportAdmin/
├── index.html                       # Entry point
├── app.js                           # Firebase Auth + Firestore logic
├── styles.css                       # Styles
└── README.md                        # Detailed documentation
```

---

## Features

### Client (User) Features
- Browse lawyers by name, city, and 22+ legal categories
- View lawyer profiles with ratings, reviews, and availability
- Send hire requests to lawyers
- Real-time chat with image sharing
- Voice/video calls with AI-powered transcripts and summaries
- Submit and track legal cases
- AI-powered legal chatbot and case research
- Stripe payments and wallet system
- Save favorite lawyers
- Rate and review lawyers
- Help & support ticket system

### Lawyer Features
- Profile creation with license verification workflow
- Accept or reject client requests
- Real-time chat and calls with clients
- Publish and manage legal articles
- View notifications for new requests
- Track earnings and payment history

### Admin Features
- Dashboard with platform statistics
- View all registered lawyers and users
- Approve or reject lawyer license submissions
- Send notifications to lawyers
- Manage help & support tickets with live chat

---

## Getting Started

### Prerequisites

- Flutter SDK (>= 3.8.0)
- Dart SDK (>= 3.8.0)
- Android Studio or VS Code
- Firebase project configured
- Node.js (for Cloud Functions and Admin Portal)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/HassanAhmad5/LAWHUB.git
   cd LAWHUB
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables:**
   Create a `.env` file in the project root:
   ```env
   CLOUDINARY_CLOUD_NAME=your_cloud_name
   CLOUDINARY_UPLOAD_PRESET=your_preset
   STRIPE_PUBLISHABLE_KEY=your_stripe_key
   PAYMENT_INTENT_URL=your_cloud_function_url
   WALLET_TRANSFER_URL=your_wallet_function_url
   ```

4. **Deploy Cloud Functions:**
   ```bash
   cd functions
   npm install
   firebase deploy --only functions
   ```

5. **Run the app:**
   ```bash
   flutter run
   ```

---

## Admin Portal (Web)

The admin portal is a **Next.js** web application for managing the LawHub platform.

### Features
- Admin login (Firebase Auth)
- Dashboard with user and lawyer statistics
- View all registered lawyers and users
- Approve or reject lawyer license submissions

### Setup

```bash
cd LAWHUB-Admin-Portal
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

### Admin Login
Create an admin account in Firebase Console under **Authentication > Users**, then add a corresponding document in the `Admins` Firestore collection.

---

## Help & Support Admin (Web)

A standalone **HTML/CSS/JS** web console for managing support tickets submitted from the mobile app.

### Features
- View all open, in-progress, and resolved support tickets
- Live chat with users and lawyers
- Update ticket status (open / in-progress / resolved)
- Unread message indicators

### Firestore Schema

**Collection: `HelpSupportTickets`**

| Field | Type | Description |
|---|---|---|
| `userId` | string | Submitter's email |
| `userType` | string | `"user"` or `"lawyer"` |
| `name` | string | Submitter's full name |
| `problem` | string | Initial problem description |
| `status` | string | `open` / `in_progress` / `resolved` |
| `createdAt` | Timestamp | Ticket creation time |

**Subcollection: `HelpSupportTickets/{id}/messages`**

| Field | Type | Description |
|---|---|---|
| `text` | string | Message body |
| `senderId` | string | Sender's email |
| `senderRole` | string | `"user"` or `"admin"` |
| `createdAt` | Timestamp | Message timestamp |

### Setup

```bash
cd HelpSupportAdmin
python -m http.server 5173
# Open http://localhost:5173
```

Any static server works (VS Code Live Server, `npx serve`, Firebase Hosting, etc.).

### Creating the First Admin

1. In Firebase Console > **Authentication > Users**, create an email/password user
2. In Firestore, create an `Admins` collection and add a document with **Document ID = user's UID**:
   ```json
   { "name": "Super Admin", "email": "admin@lawhub.app" }
   ```
3. Sign in to the dashboard with those credentials

### Deployment

Any static host works — Firebase Hosting, Netlify, Vercel, or GitHub Pages.

```bash
firebase init hosting   # public dir = "."
firebase deploy --only hosting
```

---

## Firebase Setup

### Collections

| Collection | Purpose |
|---|---|
| `Users` | Registered clients |
| `Lawyers` | Registered lawyers (with verification status) |
| `LawyersLicense` | Pending/approved license submissions |
| `ChatRooms` | Active chat conversations |
| `Cases` | Legal case records |
| `Articles` | Lawyer-authored legal articles |
| `Payments` | Payment transaction records |
| `HelpSupportTickets` | Support tickets with message subcollection |
| `Transcripts` | Call transcripts |
| `ActiveCalls` | Ongoing call sessions |
| `Admins` | Admin user records |

### Cloud Functions (Node.js 18)

| Function | Purpose |
|---|---|
| `stripePaymentIntent` | Creates Stripe payment intents |
| `walletTransfer` | Handles wallet-to-wallet transfers |

---

## Environment Variables

Create a `.env` file in the project root (do **not** commit this file):

| Variable | Description |
|---|---|
| `CLOUDINARY_CLOUD_NAME` | Cloudinary cloud name for image uploads |
| `CLOUDINARY_UPLOAD_PRESET` | Cloudinary upload preset |
| `STRIPE_PUBLISHABLE_KEY` | Stripe publishable API key |
| `PAYMENT_INTENT_URL` | Cloud Function URL for payment intents |
| `WALLET_TRANSFER_URL` | Cloud Function URL for wallet transfers |

---

## License

This project is proprietary. All rights reserved.
