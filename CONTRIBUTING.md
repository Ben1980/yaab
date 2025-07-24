# Contributing to YAAB

Thank you for your interest in contributing to YAAB! This document provides guidelines and instructions for contributing to this Alien Breed clone project.

## Code of Conduct

By participating in this project, you agree to abide by the following principles:

- Be respectful and inclusive
- Welcome newcomers and help them get started
- Focus on constructive criticism
- Respect differing viewpoints and experiences

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce** the issue
- **Expected behavior** vs what actually happened
- **Screenshots** if applicable
- **Environment details** (OS, Godot version)

### Suggesting Enhancements

Enhancement suggestions are welcome! Please provide:

- **Use case** - why this enhancement would be useful
- **Proposed implementation** - how you envision it working
- **Alternatives considered** - other approaches you've thought about

### Contributing Code

#### First Time Setup

1. Fork the repository on GitHub
2. Clone your fork locally:

   ```bash
   git clone https://github.com/YOUR_USERNAME/yaab.git
   cd yaab
   ```

3. Add the upstream repository:

   ```bash
   git remote add upstream https://github.com/ORIGINAL_OWNER/yaab.git
   ```

4. Create a feature branch:

   ```bash
   git checkout -b your-feature-name
   ```

#### Development Process

1. **Before starting work**, sync with upstream:

   ```bash
   git fetch upstream
   git checkout main
   git merge upstream/main
   ```

2. **Make your changes**:
   - Follow the existing code style
   - Test your changes thoroughly
   - Add comments for complex logic

3. **Commit your changes**:

   ```bash
   git add .
   git commit -m "Add feature: brief description"
   ```

   Commit message guidelines:
   - Use present tense ("Add feature" not "Added feature")
   - Keep the first line under 50 characters
   - Reference issues like "Fix #123" when applicable

4. **Push to your fork**:

   ```bash
   git push origin your-feature-name
   ```

5. **Create a Pull Request** on GitHub

### Contributing Assets

When contributing art, sound, or other assets:

1. **File formats**:
   - Sprites: PNG format with transparency
   - Source files: Include .aseprite files for sprites
   - Audio: OGG Vorbis for music, WAV for sound effects

2. **Naming conventions**:
   - Use lowercase with underscores: `enemy_walk.png`
   - Be descriptive: `player_shoot_laser.wav`

3. **Asset guidelines**:
   - Match the existing pixel art style (16x16 or 32x32 base)
   - Keep file sizes reasonable
   - Ensure assets are your original work or properly licensed

### Contributing Levels

For level design using Tiled:

1. Use the existing `yaab.tiled-project`
2. Follow established tile conventions
3. Test levels thoroughly for gameplay balance
4. Include any new tilesets needed

## Pull Request Process

1. **Ensure your PR**:
   - Has a clear title and description
   - References any related issues
   - Includes only related changes (one feature per PR)
   - Has been tested in Godot 4.4.1+

2. **After submitting**:
   - Respond to code review feedback
   - Make requested changes promptly
   - Keep your PR up to date with main branch

3. **Merge criteria**:
   - Code runs without errors
   - Follows project conventions
   - Has been reviewed and approved
   - Passes any automated checks

## Development Guidelines

### Godot-Specific Guidelines

- **Scene Organization**: Keep scenes focused and modular
- **Node Naming**: Use descriptive names (PlayerSprite, EnemyCollision)
- **Signals**: Prefer signals over direct node references
- **Resources**: Reuse resources when possible

### Code Style

- **GDScript**: Follow [Godot's style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- **File Structure**: One class per file, matching the class name
- **Variables**: Use snake_case for variables and functions
- **Constants**: Use UPPER_SNAKE_CASE for constants

### Testing

Before submitting:

1. Test all new features thoroughly
2. Ensure no regressions in existing functionality
3. Check for performance issues
4. Test on different screen resolutions

## Questions?

If you have questions about contributing:

1. Check existing issues and discussions
2. Ask in the PR or issue comments
3. Open a new discussion for broader topics

Thank you for helping make YAAB better!
