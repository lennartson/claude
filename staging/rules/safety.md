# Safety Rules

## Never Do Without Explicit Approval

- `rm -rf` on any directory
- `git push --force` to main/master
- `sudo` commands
- Installing dependencies not on whitelist
- `--no-verify` to skip pre-commit hooks (NEVER - fix the issue instead)

## File Deletion Policy

- NEVER use `rm` directly - use `trash` instead
- `trash <file>` moves files to ~/.claude/.trash/ with timestamp
- Files can be recovered with `trash-restore <filename>`
- `trash-list` shows trashed files
- Only `trash-empty --force` permanently deletes (requires approval)
- Trash is outside git repos and ignored

## Dangerous Operations

| Operation | Risk | Mitigation |
|-----------|------|------------|
| Force push | Destroys history | Never to main/master |
| rm -rf | Unrecoverable | Use trash |
| sudo | System-wide | Always ask first |
| DROP TABLE | Data loss | Explicit approval |
| Hard reset | Loses commits | Soft reset preferred |

## Remote Server Safety

- NEVER transfer .env or credential files to remote servers (rsync, scp, etc.)
- NEVER create files containing secrets in /tmp or world-readable directories on servers
- If credentials must be passed to a remote service, use env vars in the orchestrator (Dokploy, Docker Swarm, etc.), never files on disk

## Environment Safety

- ALWAYS use `echo -n` when writing env vars (no trailing newlines)
- Each app needs its own .env configured locally
- Never commit .env files
- Use environment variables for all secrets
