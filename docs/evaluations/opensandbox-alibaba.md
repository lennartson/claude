# Evaluation: Alibaba OpenSandbox

**Date**: 2026-03-02
**Resource**: https://github.com/alibaba/OpenSandbox
**Category**: Infrastructure / MCP Integration / Sandbox Runtime
**Stars**: 4.2k | **Language**: Python (44%), Go (25%), TypeScript (7%)
**License**: Apache 2.0
**Last release**: server/v0.1.4 (2026-02-28) — actively maintained

---

## 1. Summary of Claim

- General-purpose sandbox platform for AI applications (code agents, GUI agents, RL training)
- Multi-language SDKs (Python, Java/Kotlin, TypeScript/JS, C#/.NET; Go on roadmap)
- Unified APIs for sandbox lifecycle + code execution + file operations
- Docker and Kubernetes runtimes (Docker is production-ready, K8s is roadmap/early)
- FQDN-based egress network controls per sandbox
- Already has a dedicated MCP server for Claude Code integration

---

## 2. Technical Reality Check

**What it actually is**: A FastAPI server (Python) that manages Docker containers as sandboxes. Each container gets an injected Go binary (`execd`) that provides an HTTP API for command execution, file ops, and Jupyter-kernel-based code interpretation. The server handles lifecycle (create/pause/resume/kill/renew TTL), and an egress sidecar (Go, using iptables/nftables) provides per-sandbox network policy.

**Category**: MCP integration + Infrastructure

**Under the hood**:
1. You run `opensandbox-server` on your host (FastAPI on port 8080)
2. It talks to Docker API to create containers from any image
3. It injects `execd` (a Go HTTP daemon) into every container via volume mount + entrypoint override
4. `execd` starts a Jupyter notebook server internally, then exposes HTTP APIs for commands, files, and code execution
5. Bridge networking with a reverse proxy means each sandbox only needs one host port
6. Optional egress sidecar intercepts DNS and applies allow/deny rules per domain

**This is not**: gVisor, Firecracker, or hardware-level isolation. It is Docker container isolation with dropped capabilities (`NET_ADMIN`, `SYS_ADMIN`, `SYS_PTRACE`, etc.), `no_new_privileges`, optional AppArmor/seccomp profiles, and PID limits. Security is "hardened Docker," not microVM.

---

## 3. Hype / Credibility Check

| Check | Assessment |
|-------|------------|
| **Evidence** | Full open-source repo, 564 commits, 47 releases, 4.2k stars. Real engineering. |
| **Specificity** | OpenAPI specs, architecture docs, working examples for Claude Code/Gemini/Codex. |
| **Terminology** | Correct usage. No buzzword inflation. |
| **Cherry-picking** | Examples are basic but honest (hello world, code interpreter). |
| **Overclaiming** | Modest claims. "General-purpose sandbox" is accurate. |
| **Engineering detail** | Deep. Full architecture doc, OpenAPI specs, egress design proposal (OSEP-0001). |
| **Just Docker with extra steps?** | Yes, essentially. But the "extra steps" (execd injection, lifecycle management, network policy, SDK abstraction) are the value. |

**Red flags found**:
- TypeScript SDK listed in architecture doc as "Roadmap" but actually exists and is published (`@alibaba-group/opensandbox@0.1.4` on npm). Documentation is inconsistent.
- MCP server is Python-only (no TS MCP server)
- Kubernetes runtime described as "roadmap" but Helm chart just released (2026-03-02). Maturity unclear.
- Egress sidecar Layer 2 (nftables IP enforcement) still marked "implementing" — DNS-only filtering can be bypassed via direct IP connections

---

## 4. Claude Code Fit Assessment

### What could it replace?

| Current | With OpenSandbox |
|---------|-----------------|
| Bash tool runs commands directly on host | Bash commands routed through sandbox container |
| No network isolation for executed code | Per-sandbox egress rules (allow pypi.org, deny everything else) |
| No resource limits on AI-generated code | CPU/memory/PID limits per sandbox |
| No filesystem isolation | Ephemeral container filesystem (destroyed on kill) |

### Integration paths (three options)

**Option A: MCP Server (ready-made)**
```bash
pip install opensandbox-mcp
claude mcp add opensandbox-sandbox --transport stdio -- \
  opensandbox-mcp --domain localhost:8080
```
This gives Claude Code 15+ new tools: `sandbox_create`, `command_run`, `file_write`, `file_read`, etc. Claude would explicitly create a sandbox, execute code inside it, and read results. This is the lowest-effort path.

**Option B: PreToolUse Hook (transparent routing)**
A hook that intercepts Bash tool calls and routes them through an existing sandbox. Higher effort, but invisible to Claude — it just uses Bash normally and the hook handles isolation. Would need custom implementation.

**Option C: TypeScript SDK direct integration**
```bash
npm install @alibaba-group/opensandbox
```
Build a custom MCP server or hook using the TS SDK. Full control but most effort.

### Context Window Impact
- MCP server adds ~15 tools to tool search (tool descriptions only loaded on match due to tool search feature)
- Zero always-loaded context cost
- No rules/skills changes needed

### Latency Impact
- Sandbox creation: ~5-15 seconds (Docker pull + container start + execd injection + health check)
- Command execution: ~200-500ms overhead per command (HTTP roundtrip to execd)
- First sandbox is slowest (image pull). Subsequent ones reuse cached image.
- TTL-based: sandbox stays alive (default 10 min), so creation cost is amortized across multiple commands

### Security Considerations
- Runs Docker on host — requires Docker daemon access
- Dropped capabilities: `AUDIT_WRITE`, `MKNOD`, `NET_ADMIN`, `NET_RAW`, `SYS_ADMIN`, `SYS_MODULE`, `SYS_PTRACE`, `SYS_TIME`, `SYS_TTY_CONFIG`
- `no_new_privileges = true`
- PID limit: 512 (prevents fork bombs)
- Optional AppArmor and seccomp profiles
- Egress DNS filtering (FQDN allowlist/blocklist)
- This is NOT microVM-level isolation — a Docker escape would compromise the host

### Compatibility
- Runs on single VPS with Docker: **YES** (this is the primary mode)
- No Kubernetes required: **YES** (Docker runtime is production-ready)
- Python server + Go execd + TypeScript SDK: all standard, no exotic dependencies
- Server install: `pip install opensandbox-server` + TOML config file
- Does not conflict with existing hooks/rules

---

## 5. What This Replaces

| Replaces | With |
|----------|------|
| Direct Bash execution on host | Isolated container execution with resource limits |
| No network control on executed code | FQDN-based egress filtering |
| No cleanup after experimental code | Ephemeral sandboxes auto-expire |
| Manual Docker commands for isolation | SDK-managed lifecycle with MCP tools |

**Does something meaningful get replaced?** Partially. The Bash tool already works well for trusted code on your own machine. OpenSandbox adds value specifically for:
1. Running untrusted/experimental AI-generated code safely
2. Giving Claude a "throwaway environment" to prototype in without polluting your host
3. Network-restricting code execution (e.g., only allow pypi.org for pip installs)

---

## 6. Scores (1-5)

| Metric | Score | Rationale |
|--------|-------|-----------|
| **Usefulness** | 3/5 | Real value for experimental code execution and isolation. But current Bash tool works fine for trusted workflows. |
| **Effort to implement** | 2/5 | MCP server is pip-installable, TS SDK is npm-installable. Server config is one TOML file. Low effort. |
| **Time to first signal** | 2/5 | Under 30 minutes to have MCP server running and test a sandbox command. |
| **Bullshit risk** | 1/5 | Legit engineering. Open source, working code, Alibaba backing. Not hype. |
| **Context cost** | 1/5 | MCP tools only. Zero always-loaded context. Tool search handles the rest. |

---

## 7. Recommendation

**MICRO-TEST**

### Reasoning

This is a well-engineered, genuinely useful tool — but the question is whether you need it today. Your current workflow executes code directly on the host via the Bash tool, and that works fine for your own projects. OpenSandbox becomes valuable when:

1. You want Claude to run experimental code without touching your host filesystem
2. You want network isolation on AI-generated code
3. You want ephemeral environments that auto-destroy
4. You build agent products that execute user-submitted code

You are not building an agent product right now. Your Claude Code setup is for personal development. The risk of AI-generated code destroying your host is low because you review tool calls. But the cost to try is also low (~30 minutes), and having a sandbox available is a nice safety net for more experimental work.

**Not ADOPT** because: you do not have a pressing problem that this solves. Direct Bash execution is fine for your workflow.
**Not PARK** because: the MCP server is ready-made for Claude Code, the setup is trivial, and it would be useful to validate the latency/UX claims firsthand.

---

## 8. Implementation Plan (MICRO-TEST)

### Prerequisites
- Docker running on VPS
- Python 3.10+ (for server)

### Setup (~30 minutes)

```bash
# 1. Install server
pip install opensandbox-server

# 2. Generate config
opensandbox-server init-config ~/.sandbox.toml --example docker

# 3. Pre-pull the code interpreter image
docker pull opensandbox/code-interpreter:v1.0.1

# 4. Start server (background)
opensandbox-server &

# 5. Install MCP server
pip install opensandbox-mcp

# 6. Register with Claude Code
claude mcp add opensandbox-sandbox --transport stdio -- \
  opensandbox-mcp --domain localhost:8080
```

### Test plan
1. Start a Claude Code session
2. Ask: "Create a sandbox, write a Python script that prints the first 20 Fibonacci numbers, run it, and show me the output"
3. Verify: sandbox creates, code executes, output returns, sandbox can be killed
4. Time the latency: how long from request to first output?
5. Test egress: create a sandbox with `networkPolicy: { defaultAction: "deny" }`, try `curl google.com` — should fail
6. Test cleanup: kill the sandbox, verify Docker container is gone

### Success criteria
- Sandbox creation under 15 seconds (image cached)
- Command execution latency under 1 second
- Egress deny actually blocks outbound traffic
- No interference with normal Claude Code Bash tool

### Rollback
```bash
claude mcp remove opensandbox-sandbox
pip uninstall opensandbox-mcp opensandbox-server
# Remove Docker images if desired
```

### Where it goes (if promoted to ADOPT)
- `staging/skills/opensandbox/SKILL.md` — usage patterns, when to use sandbox vs direct Bash
- MCP server registration in project-level `.claude/settings.json` (not global — only for projects that need isolation)

---

## 9. Comparison with Alternatives

### vs. Docker directly
OpenSandbox **is** Docker with a management layer. Raw Docker gives you the same isolation, but you would need to manually: create containers, inject execution daemons, manage lifecycle/TTL, handle file upload/download, parse output. OpenSandbox wraps all of this in SDK calls and MCP tools. If you only need one-off `docker run` commands, raw Docker is simpler. If you need programmatic lifecycle management, OpenSandbox saves significant plumbing.

### vs. Vercel Sandbox (PARKED earlier)
Vercel Sandbox uses Firecracker microVMs — stronger isolation than Docker containers. But it is a managed cloud service, while OpenSandbox runs on your own VPS. For your VPS-based workflow, OpenSandbox is the better fit. Vercel Sandbox is the better choice if you are building a SaaS product that executes untrusted user code.

### vs. Claude Code's built-in Bash tool
The Bash tool runs on the host with your user's permissions. OpenSandbox runs in an isolated container with dropped capabilities and optional network restrictions. They complement each other: use Bash for trusted project work, use sandbox for experimental/untrusted execution.

---

## 10. Caveats / Missing Info

- **Isolation is Docker-level, not microVM-level.** A container escape = host compromise. For personal dev this is fine; for multi-tenant production you would want Firecracker/gVisor.
- **Egress Layer 2 (nftables) is still "implementing."** DNS-only filtering can be bypassed if code connects to IPs directly rather than domains.
- **MCP server is Python-only.** If you want a TS MCP server, you would build it yourself using the TS SDK.
- **No persistent storage yet** (on roadmap). Sandboxes are ephemeral — files are lost on kill. Volume mounting from host is supported but defeats some isolation benefits.
- **TS SDK is v0.1.4.** Early. API surface could change.
- **The "Claude Code example" in their repo is not an integration with your Claude Code.** It runs Claude Code CLI *inside* a sandbox — the opposite direction. The MCP server is what integrates Claude Code with sandboxes.
