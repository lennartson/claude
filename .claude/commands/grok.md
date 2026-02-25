# Grok Command

**Purpose**: Fetch X.com/Twitter content using Grok, then evaluate it using the EVALUATE.md framework.

**Usage**: `/grok <X.com URL>`

---

## What This Does

1. Fetches tweet content via Grok (bypasses X.com's bot blocking)
2. Automatically evaluates the content using the full EVALUATE.md framework
3. Provides a recommendation: IGNORE, PARK, MICRO-TEST, or ADOPT

---

## Instructions

### Step 1: Validate URL

Must match `https?://(twitter\.com|x\.com)/`

### Step 2: Fetch Content

Run the fetcher:
```bash
node tools/x-evaluator/fetch-x-post-openrouter.js "$ARGUMENTS"
```

### Step 3: Display Fetched Content

Show the user what was retrieved:
- Author name and handle
- Timestamp
- Full post text
- Thread content (if applicable)
- Media descriptions (if any)

### Step 4: Evaluate

Apply the complete evaluation framework from [EVALUATE.md](../../EVALUATE.md):

1. **Summary** - What is this resource claiming to offer?
2. **Technical Classification** - What category does it fall into?
3. **Hype Check** - Is this substance or marketing?
4. **Fit Assessment** - Does it match our stack and workflow?
5. **Replacement Analysis** - What does it replace? Is that better?
6. **Scoring** - Rate across 6 dimensions (0-10 each)
7. **Recommendation** - IGNORE, PARK, MICRO-TEST, or ADOPT
8. **Implementation Plan** - If adopting, what exact changes to `staging/`?
9. **Caveats** - What could go wrong?

### Step 5: Track

If ADOPT or MICRO-TEST:
- Save full evaluation to `docs/evaluations/<slug>.md`
- Add entry to [RESEARCH.md](../../RESEARCH.md)

---

## Requirements

- `.env` file in project root with `OPENROUTER_API_KEY`
- If missing, tell the user:
  ```
  Create .env in the project root:
  OPENROUTER_API_KEY="sk-or-v1-..."

  Get your key from: https://openrouter.ai/keys
  ```

---

## Error Handling

If the script fails:
- Check if `.env` exists and has `OPENROUTER_API_KEY`
- Check if the URL is valid X.com/Twitter format
- Report the actual error message to the user

---

## Example

```
/grok https://x.com/anthropicai/status/1234567890
```

Fetches the tweet, then provides a full evaluation with recommendation.
