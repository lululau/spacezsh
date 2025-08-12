# CRUSH Configuration for spacezsh

## Build/Lint/Test Commands
- `source ~/.spacezsh/init.zsh` - Source the init file to apply changes
- `zsh -n ~/.spacezsh/init.zsh` - Check for syntax errors
- `zsh -x ~/.spacezsh/init.zsh` - Run with execution tracing
- `shellcheck ~/.spacezsh/*.zsh` - Lint all zsh files
- `shellcheck ~/.spacezsh/layers/*.zsh` - Lint layer files

## Code Style Guidelines

### General
- Use 2-space indentation
- Keep lines under 80 characters
- Use lowercase for variable names
- Use uppercase for environment variables

### Functions
- Use `function name()` syntax
- Keep functions short and focused
- Add comments explaining complex logic

### Variables
- Prefer local variables inside functions
- Use descriptive names for global variables
- Export only necessary environment variables

### Conditionals
- Use `[[ ... ]]` for test expressions
- Always use explicit `then` and `fi`
- Format with proper spacing: `if [[ condition ]]; then`

### Error Handling
- Check return values of critical commands
- Use `set -e` to exit on error in scripts
- Provide meaningful error messages

### Modules
- Each layer should have a clear single purpose
- Use `has` function to check dependencies
- Use `init` function as entry point

### Comments
- Use `#` for inline comments
- Add module-level comments explaining purpose
- Comment complex or non-obvious logic

## Project Structure
- Root contains core configuration
- Layers directory contains feature modules
- Init.zsh sources all layers in order
- Help.zsh provides documentation