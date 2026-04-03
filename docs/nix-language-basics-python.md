# Nix language basics (compared to Python)

A short guide for reading Nix files if you already know Python. Nix is **not** a general-purpose scripting language: it describes **values** (configs, package graphs) that get **evaluated** to produce a result.

---

## 1. Mental model: Python vs Nix

| Idea | Python | Nix |
|------|--------|-----|
| Execution | Runs top to bottom; state changes | **Pure**: no mutable globals; same input → same output |
| Evaluation order | Mostly eager | **Lazy**: values are computed when needed |
| “Variables” | `x = 1` then `x = 2` | **Bindings**, not mutation: names are set once per scope |
| Building blocks | Statements (`if`, `for`, `def`) | **Expressions** only: everything evaluates to a value |
| Side effects | File I/O, network anytime | Evaluation should be **deterministic**; I/O is explicit (e.g. builders, `builtins.fetchurl`) |

---

## 2. Values, types, and literals

| Python | Nix |
|--------|-----|
| `"hello"` | `"hello"` (double quotes; string interpolation: `"${name}"`) |
| `42`, `3.14` | `42`, `3.14` |
| `[1, 2, 3]` | `[ 1 2 3 ]` (spaces; commas optional) |
| `{"a": 1, "b": 2}` | `{ a = 1; b = 2; }` (**attribute set** / “attrset”; like a dict, keys are usually identifiers) |
| `True` / `False` | `true` / `false` |
| `None` | `null` |

**Comments:** `#` to end of line (like Python).

**Multiline strings** (common for shell snippets):

```nix
''
  line one
  line two
''
```

---

## 3. “Variables”: `let` and function arguments

Python allows reassignment:

```python
x = 1
x = 2
```

In Nix you **bind** names in a scope; you do not mutate:

```nix
let
  x = 1;
  y = x + 10;
in
  y
```

- `let ... in ...` introduces bindings; the expression after `in` is the **result** of the whole thing (here: `12`).
- Function arguments are another way to bind names (see below).

There is **no** `x = x + 1` style mutation.

---

## 4. Functions: no `return`, last expression wins

Python:

```python
def add(a, b):
    return a + b
```

Nix functions are **anonymous** unless you bind them in `let`. Arguments are **one at a time** (curried): `a: b: a + b` means “a function that takes `a`, returns a function that takes `b`”.

```nix
let
  add = a: b: a + b;
in
  add 2 3
```

- There is **no** `return`. The body is an expression; its value is the function’s result.
- **Call** by **juxtaposition**: `add 2 3`, not `add(2, 3)`.

**One argument that is an attrset** (common for options; feels like kwargs):

```nix
let
  greet = { name, title ? "Mr" }: "${title} ${name}";
in
  greet { name = "Lee"; }
```

This is similar in spirit to Python:

```python
def greet(*, name, title="Mr"):
    return f"{title} {name}"
```

---

## 5. Conditionals: `if` **must** have `else`

Python:

```python
x = a if cond else b
```

Nix (expression only; **else is required**):

```nix
if cond then a else b
```

There is no `elif`; nest `if` or use a helper.

---

## 6. Attribute sets: access, `inherit`, merge

**Access** with dot (keys must exist or you need `?.` patterns / `lib.optionalAttrs` in real code):

```nix
let
  p = { x = 1; y = 2; };
in
  p.x
```

**`inherit`** copies a name from the surrounding scope into the attrset (saves repetition):

```nix
let
  version = "1.0";
in
{
  inherit version;
  pname = "my-app";
}
```

Rough Python equivalent:

```python
version = "1.0"
{ "version": version, "pname": "my-app" }
```

**Merge** two attrsets (right side wins on key clashes):

```nix
{ a = 1; b = 2; } // { b = 3; c = 4; }
# → { a = 1; b = 3; c = 4; }
```

---

## 7. “Imports” and splitting files

Python:

```python
from m import x
```

Nix:

```nix
import ./something.nix
```

- `import` takes a **path** and evaluates that file to **one Nix value** (often a function).
- Typical pattern: a file exports a **function** that expects `{ pkgs, ... }` or `{ config, pkgs, ... }` (module arguments).

Example: `packages.nix` often looks like:

```nix
{ pkgs }:
[
  pkgs.git
  pkgs.htop
]
```

That means: “this file is a function; call it with an attrset that includes `pkgs`.”

---

## 8. Flakes: `inputs` and `outputs` (Nix-specific)

A **flake** (`flake.nix`) wires **external sources** (inputs) to **what you expose** (outputs).

| Concept | Role |
|--------|------|
| **`inputs`** | Pinned dependencies: `nixpkgs`, `home-manager`, `darwin`, etc. Each has `url` / `flake` options and ends up in `flake.lock`. |
| **`outputs = inputs: ...`** | A function: given all resolved inputs, you return attrsets of **packages**, **darwinConfigurations**, **homeConfigurations**, etc. |
| **`inputs.self`** | This flake’s own source (useful for referring to files in the repo). |

You will see patterns like:

```nix
outputs = inputs@{ self, nixpkgs, ... }: {
  darwinConfigurations."hostname" = nixpkgs.lib.darwinSystem { ... };
};
```

`inputs@` binds the whole inputs attrset to `inputs` **and** lets you list names in one place.

**Rough analogy (incomplete):** `inputs` is like pinned `requirements.txt` / lockfile sources; `outputs` is like “what this project publishes” (not like Python `print` output—think “output schema of the flake”).

---

## 9. Useful builtins (skim when reading code)

| Name | Role |
|------|------|
| `import` | Load and evaluate another `.nix` file |
| `map f list` | Like Python `map` (lazy list) |
| `builtins.attrNames set` | List of keys of an attrset |
| `lib` (from nixpkgs) | Huge helper library (`optionalAttrs`, `mkIf`, `foldl'`, …) |

For day-one reading, recognizing **`let`/`in`**, **functions `a: b: ...`**, **`{ pkgs }: ...`**, and **`if/then/else`** covers most config.

---

## 10. Cheat sheet: Python → Nix

| Python | Nix |
|--------|-----|
| `def f(x): return x * 2` | `f = x: x * 2;` |
| `lambda x: x * 2` | `x: x * 2` |
| `d["key"]` | `d.key` or `d."weird-key"` |
| `{**a, **b}` (merge dicts) | `a // b` |
| list comprehension | `map (x: x * 2) list` or `genList` / `imap0` (varies) |
| `for` loops | Usually `map`, `foldl'`, or `lib.genAttrs`—no imperative `for` |

---

## 11. Further reading

- [Nix language basics](https://nixos.org/manual/nix/stable/language/index.html) (official manual)
- [nix.dev tutorials](https://nix.dev/tutorials)

This repo’s entry points: `flake.nix` (inputs/outputs), `configuration.nix` (system), `packages.nix` (`{ pkgs }: [ ... ]`), `home/default.nix` (Home Manager imports).
