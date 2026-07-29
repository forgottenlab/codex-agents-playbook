# Security Policy

## Supported versions

This repository currently publishes documentation and scripts from the `main` branch. No stable security-support window is promised before the first tagged release.

## Reporting a security issue

Do not open a public issue containing API keys, tokens, passwords, private keys, private URLs, production identifiers, or sensitive logs.

Use GitHub's private vulnerability reporting feature when enabled. If private reporting is unavailable, open a minimal public issue that contains no sensitive value and asks the maintainer for a private contact route.

## Security model

This project provides prompt-level operating rules and local helper scripts. It does not provide:

- an operating-system sandbox;
- authentication or authorization enforcement;
- a complete secret scanner;
- protection from every malicious repository or command;
- a substitute for Git review, backups, least privilege, and platform permissions.

Review scripts before running them, especially when using a fork or untrusted branch.
