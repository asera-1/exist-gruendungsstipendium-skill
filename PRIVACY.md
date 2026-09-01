# Privacy guidance

## Data boundary

This repository contains no applicant database, telemetry, hosted service, credentials, or analytics. The skill runs inside the Claude, ChatGPT, or Codex environment chosen by the user. Files, prompts, web access, retention, training use, connectors, and other tool calls are therefore governed by that host, the user's plan and workspace settings, and any enabled third party.

Do not interpret this repository's lack of telemetry as a guarantee that a model host retains no data.

## Sensitive application material

Treat the following as confidential unless the data owner has explicitly made it public:

- unpublished technology, source code, datasets, research results, and IP strategy;
- customer, partner, pricing, financial, and market-entry information;
- CVs, certificates, signatures, identity and residence documents;
- addresses, birth dates, personal contact details, identification numbers, and bank information;
- reviewer correspondence and institution-specific internal material.

Minimize first. Redact unnecessary identifiers before uploading files or pasting text. Use synthetic placeholders in demonstrations, issues, tests, and pull requests.

Removing obvious identifiers is not necessarily anonymization. Treat material as personal data while a person could still be identified from context, roles, dates, institutions, CV details, or combined information.

## GDPR responsibility

This project is not a legal assessment and cannot certify a workflow as GDPR-compliant. Where GDPR applies, the responsible controller must determine the purpose and lawful basis for each processing or transfer step and address transparency, controller/processor roles, provider terms, retention and deletion, subprocessors, security, data-subject rights, and international transfers as applicable.

Permission to use confidential material and a GDPR lawful basis are different questions. A founder's or data owner's authorization does not automatically make every processing step lawful. Institutional users should use an organization-approved environment and involve their data-protection contact when the basis or configuration is uncertain.

## Web and external-tool use

Use official program pages and generic searches wherever possible. Do not include confidential project names, personal data, unpublished claims, document excerpts, customer identities, or private URLs in web searches, query strings, external tools, or third-party uploads unless the transfer is necessary, specifically permitted for confidentiality, and covered by the responsible controller's process and lawful basis.

Browsing a public official source is not authorization to send applicant information to that source or any other third party.

Before using applicant material, verify the chosen host's current training/model-improvement controls, retention and deletion rules, workspace administration, subprocessors, connectors, browsing behavior, and international-transfer terms. Product names and settings change; consult current provider documentation rather than relying on this repository alone. The distributable package includes the same checklist in [privacy and data handling](exist-gruendungsstipendium/references/privacy-and-data-handling.md).

## Publishing and contributions

Never commit or attach a real application, evidence bundle, reviewer letter, identity document, or recognizable applicant narrative to this repository. Do not reproduce, lightly paraphrase, or disclose the provenance of confidential third-party material.

Released guidance must be independently written or otherwise licensed for publication. Experience-derived quality principles must remain abstract and non-identifying; third-party wording, identity, provenance, distinctive facts, figures, tables, diagrams, or recognizable combinations must not enter the public project.

Before contributing:

1. replace all people, institutions, companies, products, customers, figures, and dates with genuinely synthetic data;
2. inspect document metadata, comments, filenames, archive contents, and Git history;
3. run `pwsh ./scripts/Test-Release.ps1`;
4. review the staged file list manually.

## Temporary files

Keep temporary extraction, render, and analysis files outside the release payload. Delete them when they are no longer needed and when deletion is authorized. Never assume `.gitignore` makes an already committed file private; remove sensitive history using an appropriate incident-response process and rotate any exposed credential.
