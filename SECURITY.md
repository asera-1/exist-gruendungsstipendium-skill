# Security policy

## Supported versions

| Version | Supported |
|---|---|
| 0.1.x | Yes |
| Earlier or unreleased copies | No |

Support means that confirmed security or privacy defects are considered for the next patch release. It does not guarantee uninterrupted maintenance or program-rule accuracy.

## Reporting a vulnerability

Use GitHub's private vulnerability-reporting or Security Advisory feature for this repository when it is available. Do not place exploit details, credentials, unpublished applicant information, personal data, or confidential documents in a public issue.

If private reporting is not enabled, open a minimal public issue requesting a private contact channel. Include no sensitive details in that issue.

Useful reports identify:

- the affected version and file;
- the privacy or security boundary that can be bypassed;
- a synthetic reproduction that contains no real applicant information;
- the expected safe behavior;
- any practical mitigation.

## Scope

In scope:

- instructions that could cause unauthorized disclosure, external contact, submission, or attestation;
- prompt-injection weaknesses involving uploaded or retrieved material;
- accidental inclusion of credentials, personal data, confidential application material, or local paths in a release;
- unsafe archive paths or release-build behavior;
- misleading privacy or data-handling claims.

Out of scope:

- disagreements with official EXIST decisions;
- outdated program information already handled by the skill's mandatory current-source refresh;
- model-provider availability or provider-side data practices;
- reports that require publishing real applicant data.

This repository contains Markdown instructions and local release scripts. It operates inside the user's chosen AI environment and inherits that environment's permissions and security controls.
