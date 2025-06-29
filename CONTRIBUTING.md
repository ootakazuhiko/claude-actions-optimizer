# Contributing to Claude Actions Optimizer

We love your input! We want to make contributing to Claude Actions Optimizer as easy and transparent as possible.

## Development Process

1. Fork the repo and create your branch from `main`
2. If you've added code that should be tested, add tests
3. If you've changed APIs, update the documentation
4. Ensure the test suite passes
5. Make sure your code follows the existing style
6. Issue that pull request!

## Testing

Test your changes with different project types:

```bash
# Node.js project
./quick-deploy.sh test-nodejs nodejs

# Python project  
./quick-deploy.sh test-python python

# Generic project
./quick-deploy.sh test-generic generic
```

## Pull Request Process

1. Update the README.md with details of changes to the interface
2. Update the docs/ with any new functionality
3. The PR will be merged once you have the sign-off of at least one maintainer

## Code Style

- Shell scripts: Use shellcheck for validation
- JavaScript: Standard style (no semicolons)
- Documentation: Clear, concise, and helpful

## License

By contributing, you agree that your contributions will be licensed under its MIT License.