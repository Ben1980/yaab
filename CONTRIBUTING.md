# Contributing to YAAB

First off, thank you for considering contributing to YAAB! It's people like you that make YAAB such a great tool.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Style Guide](#style-guide)
- [Community](#community)

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## How Can I Contribute?

### 🐛 Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When you create a bug report, include as many details as possible using our [bug report template](.github/ISSUE_TEMPLATE/bug_report.md).

**Great bug reports include:**

- A clear, descriptive title
- Steps to reproduce the behavior
- Expected behavior vs actual behavior
- Screenshots (if applicable)
- Environment details (OS, browser, version)

### 💡 Suggesting Features

Feature requests are welcome! Please use our [feature request template](.github/ISSUE_TEMPLATE/feature_request.md).

**Great feature requests include:**

- Clear problem statement: "I'm frustrated when..."
- Proposed solution
- Alternative solutions you've considered
- Additional context

### 📝 Improving Documentation

Documentation improvements are always welcome! This includes:

- Fixing typos
- Adding examples
- Clarifying confusing sections
- Translating documentation

### 🔧 Submitting Code

Look for issues labeled `good first issue` or `help wanted` for great places to start.

## Development Setup

### Prerequisites

- [Godot 4.6](https://godotengine.org)

1. **Update documentation** if you've changed APIs or added features.

## Submitting

1. Push your branch to your fork:
2. Open a Pull Request against the `main` branch.
3. Fill out the PR template completely.
4. Wait for review. We aim to respond within 7 days.

### PR Checklist

- [ ] My code follows the project's style guidelines
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes

## Style Guide

### Commit Messages

We follow [Conventional Commits](https://conventionalcommits.org/):

```
(): 

[optional body]

[optional footer]
```

**Types:**

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, missing semicolons, etc.
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `test`: Adding missing tests
- `chore`: Maintenance tasks

**Examples:**

```
feat(auth): add OAuth2 support
fix(api): handle null response from payment provider
docs(readme): update installation instructions
```

### Testing

- All new features must include tests
- Bug fixes should include regression tests
- Aim for >80% code coverage on new code
- Tests should be deterministic (no flaky tests)

## Community

- [Discord](https://discord.gg/[invite-code]) - Chat with maintainers
- [Discussions](https://github.com/[owner]/[repo]/discussions) - Ask questions

## Recognition

Contributors are added to our [CONTRIBUTORS.md](CONTRIBUTORS.md) file and mentioned in release notes for significant contributions.

---

Thank you for contributing! 🎉
