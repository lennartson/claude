#!/usr/bin/env python3
# Field Theory Librarian Hook v2.0
"""
State-Enforced Librarian Hook (Global)
Works in any directory. Creates job files when threshold is reached.
All artifacts stored centrally in ~/.fieldtheory/librarian/artifacts/
PreToolUse hook handles auto-approval - no permissions needed.

Config is synced by Field Theory app to ~/.fieldtheory/librarian/config.json
"""
import json
import os
import sys
import fcntl
from pathlib import Path
from datetime import datetime

DEFAULT_RULE_CONTENT = """Write a short reflective story (120–200 words) that connects the current work to science, technology, companies, history, biology, chemistry, or physics. Stories are memorable. Don't hallucinate.

Default behavior:
	•	Be grounded, calm, and practical.
	•	Make the connection feel natural but also surprising.
	•	Favor novelty.

Occasionally—but not predictably—shift modes and do one of the following:
	•	Reveal an adjacent historical or technical parallel that reframes the work.
	•	Introduce a concept from another discipline that subtly changes how the problem can be seen.

Avoid forced cleverness.
Avoid maximalism."""

def main():
    # Get project root from environment (set by Claude Code)
    project_root = Path(os.environ.get('CLAUDE_PROJECT_DIR', os.getcwd()))
    project_name = project_root.name  # Just the directory name

    # Read global config from ~/.fieldtheory/librarian/ (synced by Field Theory app)
    central_dir = Path.home() / ".fieldtheory" / "librarian"
    config_path = central_dir / "config.json"
    state_path = central_dir / "state.json"

    if not config_path.exists():
        return

    with open(config_path) as f:
        cfg = json.load(f)

    enabled = cfg.get("enabled", False)
    if not enabled:
        return

    # Read rule_content from config (includes user expertise if set)
    rule_content = cfg.get("rule_content", DEFAULT_RULE_CONTENT)

    # Read threshold and mute status from state.json (managed by app's game mechanics)
    threshold = 7  # Default
    muted_until = 0
    if state_path.exists():
        try:
            with open(state_path) as f:
                state = json.load(f)
                threshold = state.get("threshold", 7)
                muted_until = state.get("mutedUntil", 0)
        except:
            pass

    if not isinstance(threshold, int) or threshold <= 0:
        threshold = 7

    # Check if muted for today
    import time
    if muted_until and time.time() * 1000 < muted_until:
        return  # Muted, skip artifact generation

    jobs_dir = central_dir / "jobs"
    artifacts_dir = central_dir / "artifacts"

    # Create directories
    jobs_dir.mkdir(parents=True, exist_ok=True)
    artifacts_dir.mkdir(parents=True, exist_ok=True)

    lock_file = central_dir / ".lock"
    seq_file = central_dir / ".seq"

    # Use fcntl for cross-platform file locking
    with open(lock_file, "w") as lf:
        fcntl.flock(lf.fileno(), fcntl.LOCK_EX)

        # Read current count from state.json
        count = 0
        if state_path.exists():
            try:
                with open(state_path) as f:
                    state = json.load(f)
                    count = state.get("count", 0)
            except:
                pass

        count += 1

        # Update count in state.json
        state_data = {"count": count, "threshold": threshold}
        with open(state_path, "w") as f:
            json.dump(state_data, f, indent=2)

        if count < threshold:
            return

        # Reset count
        state_data["count"] = 0
        with open(state_path, "w") as f:
            json.dump(state_data, f, indent=2)

        # Increment global seq
        seq = 0
        if seq_file.exists():
            try:
                seq = int(seq_file.read_text().strip())
            except:
                seq = 0
        seq += 1
        seq_file.write_text(str(seq))

        # Generate timestamp-based filename
        timestamp = datetime.now().strftime("%Y-%m-%d-%H%M%S")
        job_file = jobs_dir / f"job_{seq}.json"
        out_file = artifacts_dir / f"{project_name}-{timestamp}-artifact.md"

        # 1. Check if job already exists and is done (prevent regression)
        job_is_done = False
        if job_file.exists():
            try:
                existing_job = json.loads(job_file.read_text(encoding="utf-8"))
                if existing_job.get("status") == "done":
                    job_is_done = True
            except (json.JSONDecodeError, OSError):
                pass  # Treat malformed as not-done

        # 2. Create job file if missing (idempotent per seq)
        if not job_file.exists():
            job_data = {
                "schema_version": 1,
                "id": seq,
                "type": "history_artifact",
                "status": "pending",
                "project": project_name,
                "project_path": str(project_root),
                "output": str(out_file),
                "created_at": datetime.now().isoformat()
            }
            job_file.write_text(json.dumps(job_data, indent=2) + "\n")

        # 3. Output additionalContext with ALL details (no file reads needed)
        if not job_is_done:
            msg = f"""[STATE-ENFORCED] Before responding, write this artifact:

OUTPUT: {out_file}
RULE: {rule_content}
THEN: Update {job_file} setting "status" to "done"

Use the current conversation as context. Write the artifact first, then mark the job done."""
            print(json.dumps({
                "hookSpecificOutput": {
                    "hookEventName": "UserPromptSubmit",
                    "additionalContext": msg
                }
            }))

if __name__ == "__main__":
    main()
