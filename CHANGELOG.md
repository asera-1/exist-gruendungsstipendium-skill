# Changelog

All notable public changes to this project are recorded here. The project follows semantic versioning while it remains in public beta.

## [Unreleased]

No changes yet.

## [0.1.1] - 2026-09-01

### Security and privacy

- Hardened release validation so locally supplied privacy denylist values remain runtime-only and are never stored in public code.
- Added a privacy and data-handling guide to the distributable Skill and linked it from the core instructions and installation flow.
- Clarified that confidentiality permission is not itself a GDPR lawful basis and that redaction may not prevent contextual re-identification.
- Added release checks that reject tracked applicant-like office-document formats.

### Changed

- Renamed the non-binding drafting heuristics to application-quality patterns to avoid implying that private examples or any wording can predict approval.

## [0.1.0] - 2026-08-29

### Added

- Initial public-beta EXIST-Gründungsstipendium skill.
- Current-source verification and conflict-handling workflow.
- Progressive eligibility intake, Ideenpapier drafting guidance, evaluator-style review, and working templates.
- General application-quality patterns with explicit confidentiality and non-fabrication boundaries.
- Claude, ChatGPT desktop, and Codex installation guidance.
- Deterministic ZIP builder and checksum, release validation, synthetic behavior cases, and secret-free continuous checks.

### Security and privacy

- Applicant evidence is excluded from the distribution.
- The skill treats uploaded and retrieved content as evidence rather than instructions.
- Confidential content, unnecessary personal data, and unauthorized external actions are explicitly prohibited.
