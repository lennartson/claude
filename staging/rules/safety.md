# Safety Rules

## Never Do Without Explicit Approval

- `rm -rf` on any directory
- `git push --force` to main/master
- `sudo` commands
- Installing dependencies not on whitelist
- `--no-verify` to skip pre-commit hooks (NEVER - fix the issue instead)
- Cloud resource deletion (gcloud, aws, cdk, terraform)
- Docker service/stack/network removal
- SSH commands containing destructive operations

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
| gcloud delete | Cloud resource loss | NEVER run from Claude |
| aws delete/terminate | Cloud resource loss | NEVER run from Claude |
| terraform destroy | Complete infra loss | NEVER run from Claude |
| cdk destroy | Stack teardown | NEVER run from Claude |
| docker service/stack rm | Service disruption | NEVER run from Claude |

## Cloud Infrastructure Safety

- NEVER run `gcloud ... delete` or `gcloud storage rm` — cloud resource deletion is irreversible
- NEVER run `aws s3 rm`, `aws s3 rb`, or `aws <service> delete-*` — these destroy cloud resources
- NEVER run `aws <service> terminate-*` — this kills running infrastructure
- NEVER run `cdk destroy` — this tears down CloudFormation stacks
- NEVER run `terraform destroy`, `terraform taint`, or `terraform apply -auto-approve`
- NEVER run `terraform state rm` — this causes drift and orphaned infrastructure
- If infrastructure changes are needed, present the commands for the user to run manually

## Docker Safety

- NEVER run `docker system prune` — removes all unused resources
- NEVER run `docker volume rm/remove/prune` — permanently deletes persistent data
- NEVER run `docker service rm` or `docker stack rm` — tears down running services
- NEVER run `docker network rm/prune` — disconnects running containers
- NEVER run `docker compose down -v` or `--volumes` — the volume flag deletes data
- Safe: `docker compose down` (without -v), `docker ps`, `docker logs`, `docker inspect`

## Remote Server Safety

- NEVER transfer .env or credential files to remote servers (rsync, scp, etc.)
- NEVER transfer SSH keys (.pem, id_rsa, id_ed25519) to remote servers
- NEVER create files containing secrets in /tmp or world-readable directories on servers
- NEVER run destructive commands via SSH (rm, sudo, dd, mkfs, shutdown, etc.)
- If credentials must be passed to a remote service, use env vars in the orchestrator (Dokploy, Docker Swarm, etc.), never files on disk

## Git History Protection

- NEVER run `git reflog expire` — removes recovery points
- NEVER run `git filter-branch` — destructively rewrites history
- NEVER run `git prune` — permanently removes unreachable objects
- NEVER run `git push --mirror` — overwrites entire remote
- `git push --force` requires explicit user approval (ask mode)
- `git reset --hard` requires explicit user approval (ask mode)

## Secret Leakage Prevention

- NEVER read SSH private keys (id_rsa, id_ed25519, etc.) via bash
- NEVER read ~/.aws/credentials or ~/.aws/config via bash
- NEVER search command history for passwords/tokens/secrets
- Use the Read tool for legitimate file access — it has separate permission controls

## Protected Processes

- Port 7483 is the intel-proposals server (com.claude.intel-server). NEVER kill it.
- NEVER unload/stop any com.claude.* LaunchAgent.

## Environment Safety

- ALWAYS use `echo -n` when writing env vars (no trailing newlines)
- Each app needs its own .env configured locally
- Never commit .env files
- Use environment variables for all secrets
