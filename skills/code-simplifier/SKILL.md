---
name: code-simplifier
description: Simplifies code for clarity. Use when refactoring code for clarity without changing behavior. Use when code works but is harder to read, maintain, or extend than it should be. Use when reviewing code that has accumulated unnecessary complexity.
---

# Code Simplification

> Inspired by the [Claude Code Simplifier plugin](https://github.com/anthropics/claude-plugins-official/blob/main/plugins/code-simplifier/agents/code-simplifier.md). Adapted here as a model-agnostic, process-driven skill for any AI coding agent.

## Overview

Simplify code by reducing complexity while preserving exact behavior. The goal is not fewer lines — it's code that is easier to read, understand, modify, and debug. Every simplification must pass a simple test: "Would a new team member understand this faster than the original?"

## When to Use

- After a feature is working and tests pass, but the implementation feels heavier than it needs to be
- During code review when readability or complexity issues are flagged
- When you encounter deeply nested logic, long functions, or unclear names
- When refactoring code written under time pressure
- When consolidating related logic scattered across files
- After merging changes that introduced duplication or inconsistency

**When NOT to use:**

- Code is already clean and readable — don't simplify for the sake of it
- You don't understand what the code does yet — comprehend before you simplify
- The code is performance-critical and the "simpler" version would be measurably slower
- You're about to rewrite the module entirely — simplifying throwaway code wastes effort

## The Five Principles

### 1. Preserve Behavior Exactly

Don't change what the code does — only how it expresses it. All inputs, outputs, side effects, error behavior, and edge cases must remain identical. If you're not sure a simplification preserves behavior, don't make it.

```
ASK BEFORE EVERY CHANGE:
→ Does this produce the same output for every input?
→ Does this maintain the same error behavior?
→ Does this preserve the same side effects and ordering?
→ Do all existing tests still pass without modification?
```

### 2. Follow Project Conventions

Simplification means making code more consistent with the codebase, not imposing external preferences. Before simplifying:

```
1. Read AGENTS.md / the project's conventions file (CLAUDE.md, RULES.md, or equivalent)
2. Study how neighboring code handles similar patterns
3. Match the project's style for:
   - Import ordering and module system
   - Function declaration style
   - Naming conventions
   - Error handling patterns
   - Type annotation depth
```

Simplification that breaks project consistency is not simplification — it's churn.

### 3. Prefer Clarity Over Cleverness

Explicit code is better than compact code when the compact version requires a mental pause to parse. Two examples of the same trap:

- **Dense conditional chains** — a conditional nested inside a conditional (`isNew ? "New" : isUpdated ? "Updated" : ...`) forces the reader to hold a mental stack. The same logic as a sequence of early-return checks, or a lookup table keyed by state, parses top-to-bottom.
- **Clever one-shot data transforms** — a chained fold/reduce that builds a nested structure inline (spread upon spread, defaulting in three places) is write-once, read-forever-painful. The same accumulation with a named intermediate step — an explicit loop over a map/dict, or the language's pipeline idiom broken into named stages — is self-explanatory.

### 4. Maintain Balance

Simplification has a failure mode: over-simplification. Watch for these traps:

- **Inlining too aggressively** — removing a helper that gave a concept a name makes the call site harder to read
- **Combining unrelated logic** — two simple functions merged into one complex function is not simpler
- **Removing "unnecessary" abstraction** — some abstractions exist for extensibility or testability, not complexity
- **Optimizing for line count** — fewer lines is not the goal; easier comprehension is

### 5. Scope to What Changed

Default to simplifying the code of the current round of work — local unpushed commits plus uncommitted changes (pushed work is out of scope). Resolve the scope the same way the `review` skill does: upstream diff (`@{u}...HEAD`) → base-branch diff → ask. Avoid drive-by refactors of unrelated code unless explicitly asked to broaden scope. Unscoped simplification creates noise in diffs and risks unintended regressions.

## The Simplification Process

### Step 1: Understand Before Touching (Chesterton's Fence)

Before changing or removing anything, understand why it exists. This is Chesterton's Fence: if you see a fence across a road and don't understand why it's there, don't tear it down. First understand the reason, then decide if the reason still applies.

```
BEFORE SIMPLIFYING, ANSWER:
- What is this code's responsibility?
- What calls it? What does it call?
- What are the edge cases and error paths?
- Are there tests that define the expected behavior?
- Why might it have been written this way? (Performance? Platform constraint? Historical reason?)
- If the project uses git, check blame: what was the original context for this code? (non-git project: rely on project docs and the user)
```

If you can't answer these, you're not ready to simplify. Read more context first.

### Step 2: Identify Simplification Opportunities

Scan for these patterns — each one is a concrete signal, not a vague smell:

**Structural complexity:**

| Pattern | Signal | Simplification |
|---------|--------|----------------|
| Deep nesting (3+ levels) | Hard to follow control flow | Extract conditions into guard clauses or helper functions |
| Long functions (50+ lines) | Multiple responsibilities | Split into focused functions with descriptive names |
| Nested ternaries | Requires mental stack to parse | Replace with if/else chains, switch, or lookup objects |
| Boolean parameter flags | `doThing(true, false, true)` | Replace with options objects or separate functions |
| Repeated conditionals | Same `if` check in multiple places | Extract to a well-named predicate function |

**Naming and readability:**

| Pattern | Signal | Simplification |
|---------|--------|----------------|
| Generic names | `data`, `result`, `temp`, `val`, `item` | Rename to describe the content: `userProfile`, `validationErrors` |
| Abbreviated names | `usr`, `cfg`, `btn`, `evt` | Use full words unless the abbreviation is universal (`id`, `url`, `api`) |
| Misleading names | Function named `get` that also mutates state | Rename to reflect actual behavior |
| Comments explaining "what" | `// increment counter` above `count++` | Delete the comment — the code is clear enough |
| Comments explaining "why" | `// Retry because the API is flaky under load` | Keep these — they carry intent the code can't express |

**Redundancy:**

| Pattern | Signal | Simplification |
|---------|--------|----------------|
| Duplicated logic | Same 5+ lines in multiple places | Extract to a shared function |
| Dead code | Unreachable branches, unused variables, commented-out blocks | Remove (after confirming it's truly dead) |
| Unnecessary abstractions | Wrapper that adds no value | Inline the wrapper, call the underlying function directly |
| Over-engineered patterns | Factory-for-a-factory, strategy-with-one-strategy | Replace with the simple direct approach |
| Redundant type assertions | Casting to a type that's already inferred | Remove the assertion |

### Step 3: Apply Changes Incrementally

Make one simplification at a time, but verify in tiers — running the full test suite after every change is how a simplification pass becomes a waiting contest. Simplifications are behavior-preserving edits; match each tier to the project's fastest effective check (consult the project's AGENTS.md for the exact commands — e.g. Maven multi-module: compile one module per change, test one module per batch).

```
FOR EACH SIMPLIFICATION:
1. Make the change
2. Compile the affected module only — seconds, not minutes; no tests yet
3. Commit the simplification

FOR EACH BATCH OF 3–5 SIMPLIFICATIONS:
4. Run that module's tests
5. If a batch fails → revert the batch, re-apply one simplification at a
   time with tests to find the culprit, then continue

AFTER ALL SIMPLIFICATIONS:
6. Run the full test suite once (Step 4)
```

Tiered verification batches the test runs, not the edits — each simplification is still its own edit and commit, so a failing batch bisects one commit at a time. The small batch size keeps that bisect cheap; a full-suite run per simplification buys pinpointing you rarely need at a waiting cost you always pay.

**Submit refactoring changes separately from feature or bug fix changes.** A PR that refactors and adds a feature is two PRs — split them.

**The Rule of 500:** If a refactoring would touch more than 500 lines, invest in automation (codemods, sed scripts, AST transforms) rather than making the changes by hand. Manual edits at that scale are error-prone and exhausting to review.

### Step 4: Verify the Result

After all simplifications, run the full test suite once — the bottom-line check the per-change tiers deferred — then step back and evaluate the whole:

```
COMPARE BEFORE AND AFTER:
- Is the simplified version genuinely easier to understand?
- Did you introduce any new patterns inconsistent with the codebase?
- Is the diff clean and reviewable?
- Would a teammate approve this change?
```

If the "simplified" version is harder to understand or review, revert. Not every simplification attempt succeeds.

## Language-Idiomatic Simplification

The patterns below apply in any language — the syntax differs (Python comprehensions, Java Streams, JS array methods, Go slice operations, Rust iterators), but the underlying simplification is the same. Apply the idiom the surrounding codebase already uses.

- **Unwrap redundant async wrappers** — a function whose only action is to await a call and return its result can return the promise/future directly.
- **Collapse verbose conditional assignment** — "X if present, otherwise Y" is one line in every modern language (null-coalescing operator, `Optional.orElse`, `dict.get(key, default)`).
- **Replace manual collection-building loops** — a loop that only filters, maps, or accumulates reads better as the language's pipeline idiom (comprehensions, Stream API, iterator chains).
- **Return boolean expressions directly** — `if (cond) return true; return false;` is just `return cond;`.
- **Prefer early returns over nested conditionals** — handle the exceptional cases first so the main path reads top-to-bottom at the leftmost indentation.
- **Drop language-level ceremony** — redundant casts/type assertions the compiler already infers, single-use intermediate variables, commented-out code blocks.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "It's working, no need to touch it" | Working code that's hard to read will be hard to fix when it breaks. Simplifying now saves time on every future change. |
| "Fewer lines is always simpler" | A 1-line nested ternary is not simpler than a 5-line if/else. Simplicity is about comprehension speed, not line count. |
| "I'll just quickly simplify this unrelated code too" | Unscoped simplification creates noisy diffs and risks regressions in code you didn't intend to change. Stay focused. |
| "The types make it self-documenting" | Types document structure, not intent. A well-named function explains *why* better than a type signature explains *what*. |
| "This abstraction might be useful later" | Don't preserve speculative abstractions. If it's not used now, it's complexity without value. Remove it and re-add when needed. |
| "The original author must have had a reason" | Maybe. Check git blame — apply Chesterton's Fence. But accumulated complexity often has no reason; it's just the residue of iteration under pressure. |
| "I'll refactor while adding this feature" | Separate refactoring from feature work. Mixed changes are harder to review, revert, and understand in history. |

## Red Flags

- Simplification that requires modifying tests to pass (you likely changed behavior)
- "Simplified" code that is longer and harder to follow than the original
- Renaming things to match your preferences rather than project conventions
- Removing error handling because "it makes the code cleaner"
- Simplifying code you don't fully understand
- Batching many simplifications into one large, hard-to-review commit
- Refactoring code outside the scope of the current task without being asked

## Verification

After completing a simplification pass:

- [ ] All existing tests pass without modification (no-test projects: build compiles and a minimal runnable check passes)
- [ ] The full test suite ran once after the last simplification — per-batch module tests alone don't count
- [ ] Build succeeds with no new warnings
- [ ] Linter/formatter passes (no style regressions)
- [ ] Each simplification is a reviewable, incremental change
- [ ] The diff is clean — no unrelated changes mixed in
- [ ] Simplified code follows project conventions (checked against AGENTS.md or the project's equivalent conventions file)
- [ ] No error handling was removed or weakened
- [ ] No dead code was left behind (unused imports, unreachable branches)
- [ ] A teammate or review agent would approve the change as a net improvement

After the checklist passes, review the result through the [review-dispatch](../review-dispatch/SKILL.md) skill: simplification diffs are usually small enough to review inline in the main session; larger ones get dispatched with a ready-made review package.
