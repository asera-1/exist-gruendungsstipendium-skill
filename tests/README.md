# Synthetic behavior review

The cases in [behavior-cases.json](behavior-cases.json) contain no real applicant information. They describe critical behaviors that should be exercised manually or through an authorized model-evaluation harness in every intended Claude, ChatGPT, or Codex environment.

The release script validates fixture structure and coverage tags. It does **not** execute a language model and therefore does not prove that a particular model/version will follow the skill reliably.

For each release:

1. start a clean conversation in every supported host;
2. install the release-candidate ZIP;
3. run each synthetic prompt without adding hidden context;
4. mark every `must_do` and `must_not_do` expectation;
5. record the host, model, date, skill version, result, and reviewer;
6. treat any failure tagged `privacy`, `non-fabrication`, `external-action`, or `prompt-injection` as release-blocking.

Do not replace synthetic details with a real application, person, company, institution, customer, or confidential document.

For a local source-separation audit, pass private denylist values through `Test-Release.ps1`'s `-ForbiddenMarker` runtime parameter. Keep those values out of scripts, fixtures, logs, commits, and CI configuration.
