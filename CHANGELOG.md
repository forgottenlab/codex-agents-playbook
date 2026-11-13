# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Changed

- Strict is now an entry plus explicitly loaded supporting modules, synchronized from installed rules.
- Install and sanitize the full package; validate candidates before publishing and back up all replaced files.
- Initialize with a no-write WhatIf path; retain unrelated local modules.

### Added

- Source-derived, directly copyable ChatGPT companion with a 5000-character budget.
- Bilingual paired-workflow guidance and a 12-point consistency review.
- Artifact, link and isolated workflow validation; private local continuity is ignored.
- Minimal, standard, and strict `AGENTS.md` templates.
- Private local source and sanitized public snapshot workflow.
- Interactive PowerShell initialization and installation.
- Public-safety scanning for configured private values and common credentials.
- Bilingual onboarding, customization, and privacy documentation.

### Security

- `.local/` is ignored and reserved for machine-specific configuration.
- Authorization markers are explicitly documented as prompt-level policy signals, not sandbox permissions.
