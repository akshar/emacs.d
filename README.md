# Emacs Configuration

Modern Emacs 30 configuration with LSP, tree-sitter, and a clean modular layout. Tuned for performance in large dirs.

## Requirements

### Emacs

Install via [emacs-plus](https://github.com/d12frosted/homebrew-emacs-plus):

```bash
brew tap d12frosted/emacs-plus
brew install emacs-plus@30 --with-native-comp --with-poll --with-dragon-icon
ln -s /opt/homebrew/opt/emacs-plus@30/Emacs.app /Applications
```

- `--with-native-comp` — compiles Elisp to native code (significantly faster)
- `--with-poll` — better file watching on macOS (avoids kqueue issues)
- `--with-dragon-icon` — optional, replace with any [available icon](https://github.com/d12frosted/homebrew-emacs-plus#icons) you prefer

### System tools
```bash
brew install ripgrep              # fast search (consult-ripgrep, C-c k / C-c j)
brew install the_silver_searcher  # ag search
brew install fd                   # fast file finder (consult-fd)
pip install grip                  # Markdown preview (uses pyenv Python)
brew install enchant              # jinx spell checking
brew install cmake libvterm       # vterm terminal emulator
brew install pgformatter          # SQL formatter
```

### Credentials
- **GitHub token** (forge): add to `~/.authinfo`:
  `machine api.github.com login <username>^forge password <token>`
- **Anthropic API key** (gptel): add to `~/.authinfo`:
  `machine api.anthropic.com password <api-key>`

### Language servers & formatters
| Language | Tool | Install |
|----------|------|---------|
| Python | pyright | `npm install -g pyright` |
| Go | gopls | `go install golang.org/x/tools/gopls@latest` |
| Go (struct tags) | gomodifytags | `go install github.com/fatih/gomodifytags@latest` |
| JS/TS | typescript-language-server | `npm install -g typescript typescript-language-server` |
| JS/TS/CSS/JSON | prettier | `npm install -g prettier` |
| SQL | pgformatter | `brew install pgformatter` |
| Clojure | clojure-lsp | `brew install clojure-lsp/brew/clojure-lsp-native` |
| Clojure (Leiningen projects) | lein | `brew install leiningen` |
| Clojure (deps.edn projects) | Clojure CLI | `brew install clojure/tools/clojure` |
| Clojure (Babashka projects) | bb | `brew install borkdude/brew/babashka` |

### Tree-sitter grammars

**Option 1 — automatic (try this first):**

```
M-x treesit-auto-install-all
```

**Option 2 — manual compile (fallback if option 1 fails):**

Open `*scratch*` (`C-x b *scratch*`), paste the following, place cursor after the last `)`, and press `C-x C-e`:

```elisp
(progn
  (setq treesit-language-source-alist
    '((json       "https://github.com/tree-sitter/tree-sitter-json")
      (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
      (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
      (tsx        "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
      (go         "https://github.com/tree-sitter/tree-sitter-go")))
  (dolist (lang '(json javascript typescript tsx go))
    (treesit-install-language-grammar lang)))
```

Grammars are compiled into `~/.emacs.d/tree-sitter/` and only need to be installed once.

## Installation

1. Install system tools listed above
2. `git clone <repo-url> ~/.emacs.d`
3. Launch Emacs — packages install automatically
4. Run `M-x nerd-icons-install-fonts` and `M-x all-the-icons-install-fonts`
5. Install tree-sitter grammars (see above)
6. Restart Emacs

## Structure

```
~/.emacs.d/
├── init.el          # entry point: package setup, loads modules
├── config.el        # core: UI, completion, navigation, editing
├── lsp.el           # eglot (JS/TS) + lsp-mode (Go, Clojure)
├── ai.el            # gptel (Claude/AI chat)
├── lang/
│   ├── web.el       # treesit-auto, apheleia, web-mode, emmet, scss, json, yaml
│   ├── python.el    # lsp-pyright, virtualenvwrapper
│   ├── GO.el        # go-mode + lsp
│   ├── clojure.el   # clojure-mode, cider, paredit, clj-kondo
│   └── devops.el    # dockerfile-mode, terraform-mode, nginx-mode
├── tools/
│   └── rest.el      # restclient (.http files)
└── git/
    └── git.el       # magit, git-gutter, git-timemachine, forge
```

## Key packages

| Category | Package |
|----------|---------|
| Completion UI | vertico + orderless + marginalia |
| Search/navigation | consult + ripgrep |
| In-buffer completion | corfu + cape + nerd-icons-corfu |
| LSP (Go, Clojure) | lsp-mode + lsp-ui |
| LSP (JS/TS) | eglot (built-in, lighter weight) |
| JS/TS syntax | treesit-auto (tree-sitter grammars) |
| Formatting | apheleia (async prettier on save) |
| Theme | doom-one (doom-themes) |
| Modeline | doom-modeline + nerd-icons |
| File tree | neotree |
| Project management | projectile |
| Clojure | clojure-mode, CIDER, paredit, clj-kondo, clj-refactor |
| Git | magit, git-gutter, git-timemachine, forge |
| Snippets | yasnippet |
| Markdown preview | grip-mode (GitHub-accurate, via browser) |
| Markdown TOC | markdown-toc |
| Navigation | avy (char jump), embark (context actions), wgrep (edit grep results) |
| Help | helpful (richer describe-*) |
| Spell check | jinx (enchant-based, global) |
| Terminal | vterm |
| REST client | restclient (.http files) |
| AI | gptel (Claude/AI chat) |
| SQL | sql-indent, sqlformat (pgformatter) |
| DevOps | dockerfile-mode, terraform-mode, nginx-mode |

## Key bindings

| Key | Command |
|-----|---------|
| `C-s` | Search in buffer (consult-line) |
| `C-x b` | Switch buffer (consult-buffer) |
| `C-c k` | Ripgrep search across project |
| `C-c j` | Git grep across project (consult-git-grep) |
| `C-c p` | Projectile commands |
| `s-t` | Find file in project (projectile-find-file) |
| `s-p` | Switch project |
| `M-g f` | Jump to definition (dumb-jump) |
| `M-g b` | Jump back |
| `C-=` | Expand region |
| `C->` / `C-<` | Multiple cursors next/prev |
| `F8` | Toggle neotree |
| `C-c C-p` | Toggle Markdown live preview in Emacs (eww, side buffer) |
| `C-c C-g` | Toggle Markdown preview in browser (grip-mode, GitHub-accurate) |
| `C-x g` | Magit status |
| `s-Z` | Undo tree redo |
| `M-s` | Avy char timer jump |
| `M-i` | Highlight symbol at point (symbol-overlay) |
| `M-n` / `M-p` | Jump to next/prev symbol occurrence |
| `C-,` | Embark act (context actions) |
| `C-;` | Embark dwim |
| `M-$` | Jinx correct (spell check) |
| `C-c t` | Open vterm terminal |
| `M-x gptel` | Open AI chat buffer |

## Find and Replace (VSCode equivalent)

Emacs equivalent of VSCode's `Ctrl+Shift+H` project-wide find and replace:

1. **`C-c k`** — open `consult-ripgrep`, search for the term
2. **`C-c C-p`** in the results buffer — switch to `wgrep` (editable grep) mode
3. Edit any occurrence — changes propagate to all matched lines
4. **`C-c C-c`** — apply all edits and save affected files
5. **`C-c C-k`** — abort and discard changes

For a simple string replace across the project without grep: `C-c p r` (`projectile-replace`).

## JS/TS — Eglot

JS/TS uses **eglot** (built into Emacs 30) instead of lsp-mode:
- One tsserver instance per project root — not per `tsconfig.json`
- Async connection (`eglot-sync-connect nil`) — file opens immediately, LSP connects in background
- `documentHighlight` and `inlayHint` disabled — both are expensive in large files

To switch back to lsp-mode, see the comments in `lsp.el` — both configs are preserved.

## Performance (large dirs)

Several settings are tuned for working in large project trees:

- **`gc-cons-threshold` 64MB** — avoids constant GC pauses while typing
- **`so-long-mode`** — auto-disables font-lock, indent-bars, line numbers, git-gutter for files > 100KB
- **`jit-lock-defer-time 0.1`** — buffer appears instantly; treesitter highlighting fills in after
- **`redisplay-skip-fontification-on-input t`** — no re-highlight while typing
- **`treesit-font-lock-level 2`** — keywords/strings/functions/types only; skips fine-grained tokens
- **`projectile-indexing-method 'alien`** — uses `git ls-files` for file listing (respects `.gitignore`)
- **`git-gutter`** updates only on save (not on every keystroke or idle timer)
- **`cape-dabbrev-check-other-buffers nil`** — dabbrev only scans current buffer

## Flycheck

Flycheck runs only in modes with useful checkers: Clojure, Python, shell scripts. JS/TS and Go diagnostics are handled by eglot/flymake natively.

## Clojure

- `M-x cider-jack-in` — start REPL
- `M-c` — eval defun to comment
- `C-c C-m rr` — clj-refactor rename (prefix `C-c C-m` + refactoring shortcut)
- `M-.` — go to definition (via clojure-lsp)
- `M-x lsp-rename` — workspace rename (via clojure-lsp)
- Linting via clj-kondo (flycheck)

## Python virtualenvs

Activate a virtualenv with `M-x venv-workon`. LSP restarts automatically to pick up the new interpreter.

## SQL / PostgreSQL

- `M-x sql-postgres` — connect to a Postgres database interactively
- `C-c C-r` — send region to SQL REPL
- `C-c C-b` — send buffer to SQL REPL
- Auto-formats on save via `pgformatter` (requires `brew install pgformatter`)
- `sql-indent` provides smart indentation in `.sql` files
