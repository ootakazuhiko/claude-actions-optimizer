#!/bin/bash
# Claude Actions Optimizer - Automatic Complete Setup Script
# 全機能自動導入スクリプト

set -e

# Colors and symbols
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

SUCCESS="✅"
WARNING="⚠️"
ERROR="❌"
INFO="ℹ️"
ROCKET="🚀"
GEAR="⚙️"
CROWN="👑"

echo -e "${BLUE}${ROCKET} Claude Actions Optimizer - Complete Setup${NC}"
echo "=================================================="
echo -e "${INFO} This script will set up the complete optimization system"
echo ""

# Configuration
SETUP_TYPE=""
CLAUDE_NAME=""
CLAUDE_ROLE=""
CLAUDE_SPECIALTY=""
GITHUB_SETUP=true
INSTALL_CLIENT_ONLY=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --type)
            SETUP_TYPE="$2"
            shift 2
            ;;
        --name)
            CLAUDE_NAME="$2"
            shift 2
            ;;
        --role)
            CLAUDE_ROLE="$2"
            shift 2
            ;;
        --specialty)
            CLAUDE_SPECIALTY="$2"
            shift 2
            ;;
        --client-only)
            INSTALL_CLIENT_ONLY=true
            shift
            ;;
        --no-github)
            GITHUB_SETUP=false
            shift
            ;;
        --help)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --type <main|client>     Setup type (main=complete, client=identity only)"
            echo "  --name <name>           Claude instance name"
            echo "  --role <role>           Claude role (frontend/backend/devops/etc)"
            echo "  --specialty <list>      Specialty areas (comma-separated)"
            echo "  --client-only           Install client components only"
            echo "  --no-github             Skip GitHub repository setup"
            echo "  --help                  Show this help"
            echo ""
            echo "Examples:"
            echo "  $0 --type main --name Admin --role fullstack"
            echo "  $0 --type client --name Alice --role frontend --specialty 'React,TypeScript'"
            exit 0
            ;;
        *)
            echo -e "${ERROR} Unknown option: $1"
            exit 1
            ;;
    esac
done

# Interactive setup if no parameters provided
interactive_setup() {
    echo -e "${BLUE}${GEAR} Interactive Setup${NC}"
    echo "==================="
    
    if [ -z "$SETUP_TYPE" ]; then
        echo ""
        echo "Setup type:"
        echo "1. Main terminal (complete system setup)"
        echo "2. Client terminal (identity and coordination only)"
        read -p "Select setup type (1-2): " setup_choice
        
        case $setup_choice in
            1) SETUP_TYPE="main" ;;
            2) SETUP_TYPE="client" ;;
            *) echo -e "${ERROR} Invalid choice"; exit 1 ;;
        esac
    fi
    
    if [ -z "$CLAUDE_NAME" ]; then
        read -p "Claude instance name (e.g., Alice, Bob, Admin): " CLAUDE_NAME
    fi
    
    if [ -z "$CLAUDE_ROLE" ]; then
        echo ""
        echo "Available roles:"
        echo "1. frontend (React, UI/UX, Components)"
        echo "2. backend (API, Database, Services)"
        echo "3. devops (CI/CD, Infrastructure, Docker)"
        echo "4. fullstack (Full-stack development)"
        echo "5. testing (QA, Testing, Automation)"
        echo "6. documentation (Docs, README, Guides)"
        read -p "Select role (1-6): " role_choice
        
        case $role_choice in
            1) CLAUDE_ROLE="frontend" ;;
            2) CLAUDE_ROLE="backend" ;;
            3) CLAUDE_ROLE="devops" ;;
            4) CLAUDE_ROLE="fullstack" ;;
            5) CLAUDE_ROLE="testing" ;;
            6) CLAUDE_ROLE="documentation" ;;
            *) echo -e "${ERROR} Invalid choice"; exit 1 ;;
        esac
    fi
    
    if [ -z "$CLAUDE_SPECIALTY" ]; then
        read -p "Specialty areas (comma-separated): " CLAUDE_SPECIALTY
    fi
    
    if [ "$SETUP_TYPE" = "main" ] && [ "$GITHUB_SETUP" = true ]; then
        read -p "Setup GitHub repository labels and settings? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            GITHUB_SETUP=false
        fi
    fi
}

# Prerequisites check
check_prerequisites() {
    echo -e "${INFO} Checking prerequisites..."
    
    # Check if in git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${ERROR} Not in a git repository"
        exit 1
    fi
    
    # Check required tools
    local missing_tools=()
    
    if ! command -v git &> /dev/null; then
        missing_tools+=("git")
    fi
    
    if ! command -v curl &> /dev/null; then
        missing_tools+=("curl")
    fi
    
    if [ "$SETUP_TYPE" = "main" ] || [ "$GITHUB_SETUP" = true ]; then
        if ! command -v gh &> /dev/null; then
            missing_tools+=("gh (GitHub CLI)")
        fi
        
        if ! command -v jq &> /dev/null; then
            missing_tools+=("jq")
        fi
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo -e "${ERROR} Missing required tools: ${missing_tools[*]}"
        echo "Please install them and try again."
        exit 1
    fi
    
    # Check GitHub authentication
    if [ "$GITHUB_SETUP" = true ]; then
        if ! gh auth status &> /dev/null; then
            echo -e "${WARNING} GitHub CLI not authenticated"
            read -p "Authenticate now? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                gh auth login --web
            else
                GITHUB_SETUP=false
            fi
        fi
    fi
    
    echo -e "${SUCCESS} Prerequisites check completed"
}

# Main setup function
setup_main_system() {
    echo -e "${BLUE}${ROCKET} Setting up complete optimization system...${NC}"
    
    # Download and install base system
    if [ ! -f "CLAUDE.md" ]; then
        echo -e "${INFO} Downloading base optimization system..."
        curl -sSL -o install-base.sh https://raw.githubusercontent.com/ootakazuhiko/claude-actions-optimizer/main/install.sh
        chmod +x install-base.sh
        ./install-base.sh --preserve-existing
        rm -f install-base.sh
    fi
    
    # Download coordination and identity scripts
    echo -e "${INFO} Setting up multi-instance coordination..."
    mkdir -p scripts
    
    if [ ! -f "scripts/claude-coordinator.sh" ]; then
        curl -sSL -o scripts/claude-coordinator.sh https://raw.githubusercontent.com/ootakazuhiko/claude-actions-optimizer/main/scripts/claude-coordinator.sh
        chmod +x scripts/claude-coordinator.sh
    fi
    
    if [ ! -f "scripts/claude-identity.sh" ]; then
        curl -sSL -o scripts/claude-identity.sh https://raw.githubusercontent.com/ootakazuhiko/claude-actions-optimizer/main/scripts/claude-identity.sh
        chmod +x scripts/claude-identity.sh
    fi
    
    # Initialize coordination system
    echo -e "${INFO} Initializing coordination system..."
    ./scripts/claude-coordinator.sh init
    
    # Setup GitHub repository
    if [ "$GITHUB_SETUP" = true ]; then
        setup_github_repository
    fi
    
    echo -e "${SUCCESS} Main system setup completed"
}

# Client setup function
setup_client_system() {
    echo -e "${BLUE}${GEAR} Setting up client system...${NC}"
    
    # Verify base files exist
    if [ ! -f "CLAUDE.md" ]; then
        echo -e "${ERROR} Base system not found. Please run main setup first or pull from repository."
        exit 1
    fi
    
    # Ensure scripts are executable
    chmod +x scripts/claude-*.sh 2>/dev/null || true
    
    # Check coordination system
    if [ ! -f "scripts/claude-coordinator.sh" ]; then
        echo -e "${ERROR} Coordination system not found. Please pull latest changes from repository."
        exit 1
    fi
    
    echo -e "${SUCCESS} Client system ready"
}

# GitHub repository setup
setup_github_repository() {
    echo -e "${INFO} Setting up GitHub repository..."
    
    # Create labels for different roles
    local roles=("frontend:FF6B6B" "backend:4ECDC4" "devops:45B7D1" "fullstack:96CEB4" "testing:FFEAA7" "documentation:DDA0DD")
    
    for role_color in "${roles[@]}"; do
        local role=$(echo "$role_color" | cut -d: -f1)
        local color=$(echo "$role_color" | cut -d: -f2)
        
        gh label create "claude:$role" --color "$color" --description "Claude $role instance" 2>/dev/null || true
    done
    
    # Create workflow for tracking
    mkdir -p .github/workflows
    
    if [ ! -f ".github/workflows/claude-tracking.yml" ]; then
        curl -sSL -o .github/workflows/claude-tracking.yml https://raw.githubusercontent.com/ootakazuhiko/claude-actions-optimizer/main/templates/claude-tracking.yml 2>/dev/null || true
    fi
    
    echo -e "${SUCCESS} GitHub repository setup completed"
}

# Setup identity
setup_identity() {
    echo -e "${BLUE}${CROWN} Setting up Claude identity...${NC}"
    
    # Setup identity
    ./scripts/claude-identity.sh setup "$CLAUDE_NAME" "$CLAUDE_ROLE" "$CLAUDE_SPECIALTY" false
    
    # Load identity
    source .claude/identity/env.sh 2>/dev/null || true
    
    echo -e "${SUCCESS} Identity setup completed for $CLAUDE_NAME ($CLAUDE_ROLE)"
}

# Verify installation
verify_installation() {
    echo -e "${INFO} Verifying installation..."
    
    local errors=0
    
    # Check base files
    if [ ! -f "CLAUDE.md" ]; then
        echo -e "${ERROR} CLAUDE.md not found"
        errors=$((errors + 1))
    fi
    
    if [ ! -f ".github/workflows/draft-pr-quick-check.yml" ]; then
        echo -e "${ERROR} Draft PR workflow not found"
        errors=$((errors + 1))
    fi
    
    # Check coordination system
    if [ ! -f "scripts/claude-coordinator.sh" ]; then
        echo -e "${ERROR} Coordination script not found"
        errors=$((errors + 1))
    fi
    
    if [ ! -f "scripts/claude-identity.sh" ]; then
        echo -e "${ERROR} Identity script not found"
        errors=$((errors + 1))
    fi
    
    # Check Claude directories
    if [ ! -d ".claude" ]; then
        echo -e "${ERROR} Claude configuration directory not found"
        errors=$((errors + 1))
    fi
    
    # Check identity
    if [ ! -f ".claude/identity/current.json" ]; then
        echo -e "${ERROR} Identity configuration not found"
        errors=$((errors + 1))
    fi
    
    if [ $errors -eq 0 ]; then
        echo -e "${SUCCESS} Installation verification passed"
        return 0
    else
        echo -e "${ERROR} Installation verification failed with $errors errors"
        return 1
    fi
}

# Create test
create_verification_test() {
    echo -e "${INFO} Creating verification test..."
    
    # Create test file
    cat > test-setup.md << EOF
# Setup Verification Test

- **Claude Instance**: $CLAUDE_NAME
- **Role**: $CLAUDE_ROLE
- **Specialty**: $CLAUDE_SPECIALTY
- **Setup Time**: $(date)
- **Instance ID**: $CLAUDE_INSTANCE_ID

## System Status
- Base optimization: ✅
- Multi-instance coordination: ✅
- Identity management: ✅
- GitHub integration: $([ "$GITHUB_SETUP" = true ] && echo "✅" || echo "❌")

This file was created to verify the Claude Actions Optimizer setup.
EOF
    
    # Commit with identity
    if [ -f "scripts/claude-identity.sh" ] && [ -f ".claude/identity/current.json" ]; then
        ./scripts/claude-identity.sh commit "feat: verify Claude Actions Optimizer setup

✅ Setup completed for $CLAUDE_NAME ($CLAUDE_ROLE)
🎯 System type: $SETUP_TYPE
📊 95% cost optimization active
🤖 Multi-instance coordination enabled

Setup verification test created." test-setup.md
    else
        git add test-setup.md
        git commit -m "feat: verify Claude Actions Optimizer setup for $CLAUDE_NAME"
    fi
    
    echo -e "${SUCCESS} Verification test created and committed"
}

# Generate summary report
generate_summary() {
    echo ""
    echo -e "${GREEN}${SUCCESS} Setup Complete!${NC}"
    echo "========================"
    echo ""
    echo -e "${CROWN} Claude Instance: ${YELLOW}$CLAUDE_NAME${NC}"
    echo -e "${GEAR} Role: ${YELLOW}$CLAUDE_ROLE${NC}"
    echo -e "${INFO} Specialty: ${YELLOW}$CLAUDE_SPECIALTY${NC}"
    echo -e "${ROCKET} Setup Type: ${YELLOW}$SETUP_TYPE${NC}"
    echo ""
    
    if [ "$SETUP_TYPE" = "main" ]; then
        echo -e "${BLUE}📋 Next Steps for Main Terminal:${NC}"
        echo "1. Commit and push changes to repository"
        echo "2. Set up other client terminals"
        echo "3. Monitor system with: ./scripts/claude-coordinator.sh status"
    else
        echo -e "${BLUE}📋 Next Steps for Client Terminal:${NC}"
        echo "1. Test coordination: ./scripts/claude-coordinator.sh check"
        echo "2. Start working with: ./scripts/claude-coordinator.sh assign-role-task $CLAUDE_ROLE"
    fi
    
    echo ""
    echo -e "${PURPLE}🔗 Quick Commands:${NC}"
    echo "  Status: ./scripts/claude-identity.sh status"
    echo "  Check coordination: ./scripts/claude-coordinator.sh check"
    echo "  Create PR: ./scripts/claude-identity.sh pr \"title\" \"description\""
    echo "  Activity report: ./scripts/claude-identity.sh report 7"
    echo ""
    echo -e "${GREEN}🎉 Ready to achieve 95% cost reduction!${NC}"
}

# Main execution
main() {
    # Interactive setup if no arguments provided
    if [ -z "$SETUP_TYPE" ]; then
        interactive_setup
    fi
    
    # Prerequisites check
    check_prerequisites
    
    # Setup based on type
    if [ "$SETUP_TYPE" = "main" ] && [ "$INSTALL_CLIENT_ONLY" = false ]; then
        setup_main_system
    else
        setup_client_system
    fi
    
    # Setup identity for all installations
    setup_identity
    
    # Verify installation
    if verify_installation; then
        create_verification_test
        generate_summary
    else
        echo -e "${ERROR} Setup failed. Please check the errors above."
        exit 1
    fi
}

# Execute main function
main