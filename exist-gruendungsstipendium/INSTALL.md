# Install and start

## Privacy before use

This package is static Markdown: it has no server, telemetry, credentials, analytics, or applicant database. The Claude, ChatGPT, Codex, or other model environment that runs it still processes prompts and files under that provider's current terms, plan, settings, and enabled tools.

Before using a real application, minimize personal data and use an organization-approved account or workspace. Check current training/model-improvement controls, retention and deletion, administrators and access, connectors and web tools, subprocessors, security, and international transfers. Permission to use confidential material is not automatically a GDPR lawful basis, and removing names may not make contextual information anonymous. If the responsible organization has not approved the processing, use genuinely anonymous or synthetic placeholders and consult its privacy or data-protection contact.

Read [privacy and data handling](references/privacy-and-data-handling.md) before uploading sensitive material. This project cannot certify GDPR compliance and is not legal advice.

## Claude

1. Download the ZIP containing the `exist-gruendungsstipendium` folder.
2. On Free, Pro, or Max, enable **Code execution and file creation** under Settings → Capabilities if it is not already enabled. On Team or Enterprise, an owner must enable **Code execution and file creation** and **Skills** under Organization settings → Skills.
3. Open Customize → Skills.
4. Select `+`, then `+ Create skill`, then `Upload a skill`.
5. Upload the ZIP and enable **exist-gruendungsstipendium**.

Each user can upload the ZIP to their own account. Team and Enterprise organizations may also share or provision Skills when their administrator enables that option.

## Claude Code

Copy the complete folder to one of these locations:

- Personal: `~/.claude/skills/exist-gruendungsstipendium/`
- Project: `.claude/skills/exist-gruendungsstipendium/`

Claude Code can select it automatically or the user can invoke `/exist-gruendungsstipendium`.

## ChatGPT desktop and Codex standalone skill

The ZIP is a standalone skill. Standalone skills are supported in the ChatGPT desktop app, Codex CLI, and the Codex IDE extension. In the ChatGPT desktop app, open **Skills** in the sidebar and use the available import or upload flow for the ZIP. Availability can depend on the account and workspace settings.

For a personal Codex installation, copy the complete folder so that `SKILL.md` sits at:

`$HOME/.agents/skills/exist-gruendungsstipendium/SKILL.md`

For a repository-scoped installation, copy it to:

`$REPO_ROOT/.agents/skills/exist-gruendungsstipendium/SKILL.md`

Codex detects skill changes automatically; restart it if the skill does not appear. Invoke the skill through the skill selector, `/skills`, or `$exist-gruendungsstipendium`.

## OpenAI public distribution

A standalone skill is the authoring and local-install format. To make it installable through the universal plugin directory across ChatGPT Chat/Work surfaces and Codex, package it as an OpenAI plugin. That is a separate distribution wrapper; it does not change the application-coaching instructions in this folder.

See the current [OpenAI skill documentation](https://learn.chatgpt.com/docs/build-skills) before publishing because locations and distribution options can change.

## Public repository hygiene

Keep the distributable Skill separate from applicant work. Before publishing or rebuilding the ZIP:

- include only the Skill instructions and intentionally public supporting resources;
- never commit applications, CVs, certificates, LOIs, customer records, reviewer correspondence, generated working ledgers, chat exports, rendered pages, or extracted text;
- keep private applicant work in a separate non-public directory;
- inspect the final archive contents and search them for applicant names, project names, source filenames, private figures, and distinctive quotations.

The Skill package must contain generalized guidance only. Material supplied by its rightful user may be used for that applicant only in an appropriately approved environment, but it must never be added to the Skill, examples, tests, repository, or public release.

## Suggested first prompts

- `Use the EXIST-Gründungsstipendium Skill to check whether our project is a plausible fit. Ask the decisive questions first.`
- `Help me prepare a one-page brief for the Gründungsnetzwerk at my university.`
- `Review this Ideenpapier against the current official EXIST criteria. Do not invent missing evidence.`
- `Help me draft section 1.1 Innovation from the attached evidence.`
- `Finalize this section. Give me clean application prose first, then list unresolved evidence separately.`

## Important

The Skill does not replace the applicant institution, Gründungsnetzwerk, mentor, Projektträger Jülich, or official program documents. Current rules must be rechecked for every application.
