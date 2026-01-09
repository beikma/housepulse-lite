# Privacy Policy / Datenschutzerklärung

---

## English Version

### HousePulse Lite - Privacy Policy

**Last Updated**: January 2026

**Project by Exafion**

#### Our Commitment to Privacy

HousePulse Lite is designed with privacy as a core principle. We do not track users, serve advertisements, or sell data to third parties.

#### What Data We Process

**Authentication Data**:
- Managed by Supabase Auth
- Includes: user ID, email address (if using email authentication), authentication provider (Apple Sign-In or email)
- Used solely for user authentication and session management

**Home Data**:
- Home ID (UUID) - to identify which home you're managing
- Pairing timestamps - to track when homes were connected

**Chat Messages**:
- Message content sent to the AI assistant
- Conversation history (stored temporarily during active sessions)
- Used only to provide chat functionality and context-aware responses

**Usage Counters**:
- Daily message count per user
- Used only to enforce free-tier rate limits (50 messages/day)
- Resets automatically every 24 hours

#### MCP API Key Storage

**Client-Side (iOS)**:
- MCP API keys are stored securely in the **iOS Keychain**
- Never stored in plaintext in user defaults or files
- Protected by iOS system-level encryption

**Server-Side**:
- API keys are **never stored in plaintext**
- Keys are hashed using **SHA-256** before storage
- Hashed keys are used only to validate pairing status
- Original API keys are **never** logged or returned in responses

#### Logging

- Server logs do not contain secrets or sensitive data
- Logs include only: timestamps, endpoint names, HTTP status codes, and non-sensitive error messages
- No API keys, passwords, or personal identifiable information is logged

#### Data Retention

- Authentication data: Retained while your account is active
- Chat messages: Not permanently stored; used only for active session context
- Usage counters: Reset daily, historical data not retained
- Home pairings: Retained until you delete your account or unpair a home

#### Third-Party Services

**Supabase**:
- Provides authentication, database, and edge function hosting
- Data is stored in Supabase's infrastructure
- Subject to [Supabase Privacy Policy](https://supabase.com/privacy)

**No Other Third Parties**:
- No analytics services (e.g., Google Analytics)
- No advertising networks
- No data brokers or marketing platforms

#### Your Rights

You have the right to:
- Access your data
- Delete your account and associated data
- Export your data (upon request)
- Opt-out of the service at any time

#### Data Security

- All API communications use HTTPS encryption
- Authentication tokens are managed securely by Supabase
- Row Level Security (RLS) ensures users can only access their own data
- MCP API keys never leave your device in plaintext

#### Children's Privacy

HousePulse Lite is not intended for users under 16 years of age. We do not knowingly collect data from children.

#### Changes to This Privacy Policy

We may update this privacy policy from time to time. Significant changes will be communicated through the app or via email.

#### Contact

For privacy-related questions or requests:
- Email: [Contact email placeholder - to be added]
- GitHub Issues: https://github.com/beikma/housepulse-lite/issues

**Project by Exafion**

---

## Deutsche Version

### HousePulse Lite - Datenschutzerklärung

**Stand**: Januar 2026

**Ein Projekt von Exafion**

#### Unser Engagement für den Datenschutz

HousePulse Lite wurde mit Datenschutz als Kernprinzip entwickelt. Wir verfolgen keine Benutzer, schalten keine Werbung und verkaufen keine Daten an Dritte.

#### Welche Daten wir verarbeiten

**Authentifizierungsdaten**:
- Verwaltet von Supabase Auth
- Umfasst: Benutzer-ID, E-Mail-Adresse (bei E-Mail-Authentifizierung), Authentifizierungsanbieter (Apple Sign-In oder E-Mail)
- Wird ausschließlich für Benutzerauthentifizierung und Sitzungsverwaltung verwendet

**Heim-Daten**:
- Heim-ID (UUID) - zur Identifizierung Ihres verwalteten Hauses
- Kopplungszeitstempel - zur Verfolgung, wann Häuser verbunden wurden

**Chat-Nachrichten**:
- Nachrichteninhalte, die an den KI-Assistenten gesendet werden
- Konversationsverlauf (temporär während aktiver Sitzungen gespeichert)
- Wird nur zur Bereitstellung von Chat-Funktionalität und kontextbewussten Antworten verwendet

**Nutzungszähler**:
- Tägliche Nachrichtenanzahl pro Benutzer
- Wird nur zur Durchsetzung der kostenlosen Ratenbegrenzung verwendet (50 Nachrichten/Tag)
- Wird automatisch alle 24 Stunden zurückgesetzt

#### MCP-API-Schlüssel-Speicherung

**Client-seitig (iOS)**:
- MCP-API-Schlüssel werden sicher im **iOS Keychain** gespeichert
- Niemals im Klartext in Benutzereinstellungen oder Dateien gespeichert
- Geschützt durch iOS-Systemverschlüsselung

**Server-seitig**:
- API-Schlüssel werden **niemals im Klartext gespeichert**
- Schlüssel werden mit **SHA-256** gehasht vor der Speicherung
- Gehashte Schlüssel werden nur zur Validierung des Kopplungsstatus verwendet
- Original-API-Schlüssel werden **niemals** protokolliert oder in Antworten zurückgegeben

#### Protokollierung

- Server-Logs enthalten keine Geheimnisse oder sensiblen Daten
- Logs umfassen nur: Zeitstempel, Endpunktnamen, HTTP-Statuscodes und nicht-sensible Fehlermeldungen
- Keine API-Schlüssel, Passwörter oder persönlich identifizierbaren Informationen werden protokolliert

#### Datenspeicherung

- Authentifizierungsdaten: Werden gespeichert, solange Ihr Konto aktiv ist
- Chat-Nachrichten: Nicht dauerhaft gespeichert; nur für aktiven Sitzungskontext verwendet
- Nutzungszähler: Täglich zurückgesetzt, historische Daten nicht gespeichert
- Heim-Kopplungen: Gespeichert, bis Sie Ihr Konto löschen oder ein Heim entkoppeln

#### Drittanbieter-Dienste

**Supabase**:
- Bietet Authentifizierung, Datenbank und Edge-Function-Hosting
- Daten werden in der Infrastruktur von Supabase gespeichert
- Unterliegt der [Supabase-Datenschutzerklärung](https://supabase.com/privacy)

**Keine weiteren Drittanbieter**:
- Keine Analysedienste (z.B. Google Analytics)
- Keine Werbenetzwerke
- Keine Datenmakler oder Marketing-Plattformen

#### Ihre Rechte

Sie haben das Recht:
- Auf Zugriff auf Ihre Daten
- Ihr Konto und zugehörige Daten zu löschen
- Ihre Daten zu exportieren (auf Anfrage)
- Sich jederzeit vom Dienst abzumelden

#### Datensicherheit

- Alle API-Kommunikationen verwenden HTTPS-Verschlüsselung
- Authentifizierungstoken werden sicher von Supabase verwaltet
- Row Level Security (RLS) stellt sicher, dass Benutzer nur auf ihre eigenen Daten zugreifen können
- MCP-API-Schlüssel verlassen Ihr Gerät niemals im Klartext

#### Datenschutz für Kinder

HousePulse Lite ist nicht für Benutzer unter 16 Jahren bestimmt. Wir sammeln wissentlich keine Daten von Kindern.

#### Änderungen dieser Datenschutzerklärung

Wir können diese Datenschutzerklärung von Zeit zu Zeit aktualisieren. Wesentliche Änderungen werden über die App oder per E-Mail kommuniziert.

#### Kontakt

Für datenschutzbezogene Fragen oder Anfragen:
- E-Mail: [Kontakt-E-Mail Platzhalter - wird hinzugefügt]
- GitHub Issues: https://github.com/beikma/housepulse-lite/issues

**Ein Projekt von Exafion**
