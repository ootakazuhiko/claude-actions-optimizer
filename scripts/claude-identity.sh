#!/bin/bash
# Claude Code Identity & Role Management System
# 複数のClaude Codeインスタンスの個体識別と役割管理

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
CLAUDE_DIR="$PROJECT_ROOT/.claude"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Unicode emojis
ROBOT="🤖"
CROWN="👑"
TOOLS="🔧"
CHART="📊"
LABEL="🏷️"

# Initialize directories
init_identity_system() {
    mkdir -p "$CLAUDE_DIR"/{identity,instances,roles,reports}
    
    # Create default files if they don't exist
    [ ! -f "$CLAUDE_DIR/instances.yml" ] && echo "instances: []" > "$CLAUDE_DIR/instances.yml"
    [ ! -f "$CLAUDE_DIR/role-tasks.yml" ] && create_default_role_tasks
    [ ! -f "$CLAUDE_DIR/identity/current.json" ] && echo "{}" > "$CLAUDE_DIR/identity/current.json"
    
    echo -e "${GREEN}✅ Identity system initialized${NC}"
}

# Setup Claude identity
setup_claude_identity() {
    local name="$1"
    local role="$2"
    local specialty="$3"
    local interactive="${4:-true}"
    
    if [ "$interactive" = "true" ]; then
        echo -e "${BLUE}${ROBOT} Claude Code Identity Setup${NC}"
        echo "================================="
        
        if [ -z "$name" ]; then
            read -p "Claude instance name (e.g., Alice, Bob, Charlie): " name
        fi
        
        if [ -z "$role" ]; then
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
                1) role="frontend" ;;
                2) role="backend" ;;
                3) role="devops" ;;
                4) role="fullstack" ;;
                5) role="testing" ;;
                6) role="documentation" ;;
                *) echo "Invalid choice"; exit 1 ;;
            esac
        fi
        
        if [ -z "$specialty" ]; then
            read -p "Specialty areas (comma-separated, e.g., React,TypeScript,CSS): " specialty
        fi
    fi
    
    # Validate inputs
    if [ -z "$name" ] || [ -z "$role" ]; then
        echo -e "${RED}❌ Name and role are required${NC}"
        exit 1
    fi
    
    # Generate unique instance ID
    local timestamp=$(date +%s)
    local random_id=$(openssl rand -hex 4 2>/dev/null || echo "$$")
    export CLAUDE_INSTANCE_ID="claude-${role}-${name,,}-${timestamp}"
    export CLAUDE_NAME="$name"
    export CLAUDE_ROLE="$role"
    export CLAUDE_SPECIALTY="$specialty"
    
    # Get role emoji and color
    local role_info=$(get_role_info "$role")
    local emoji=$(echo "$role_info" | cut -d'|' -f1)
    local color=$(echo "$role_info" | cut -d'|' -f2)
    
    # Create identity file
    cat > "$CLAUDE_DIR/identity/current.json" << EOF
{
  "instance_id": "$CLAUDE_INSTANCE_ID",
  "name": "$name",
  "role": "$role",
  "specialty": "$specialty",
  "emoji": "$emoji",
  "color": "$color",
  "github_prefix": "[$role-$name]",
  "created_at": "$(date -Iseconds)",
  "last_active": "$(date -Iseconds)",
  "status": "active"
}
EOF

    # Register in instances registry
    register_instance "$CLAUDE_INSTANCE_ID" "$name" "$role" "$specialty" "$emoji" "$color"
    
    # Export to environment for current session
    cat > "$CLAUDE_DIR/identity/env.sh" << EOF
export CLAUDE_INSTANCE_ID="$CLAUDE_INSTANCE_ID"
export CLAUDE_NAME="$name"
export CLAUDE_ROLE="$role"
export CLAUDE_SPECIALTY="$specialty"
export CLAUDE_EMOJI="$emoji"
export CLAUDE_COLOR="$color"
export CLAUDE_GITHUB_PREFIX="[$role-$name]"
EOF

    echo ""
    echo -e "${GREEN}✅ Claude Identity Setup Complete:${NC}"
    echo -e "   ${LABEL} Name: ${YELLOW}$name${NC}"
    echo -e "   ${CROWN} Role: ${YELLOW}$role${NC} $emoji"
    echo -e "   ${TOOLS} Specialty: ${YELLOW}$specialty${NC}"
    echo -e "   🆔 Instance ID: ${BLUE}$CLAUDE_INSTANCE_ID${NC}"
    echo -e "   🏷️ GitHub Prefix: ${PURPLE}[$role-$name]${NC}"
    echo ""
    echo -e "${BLUE}To use this identity, source the environment:${NC}"
    echo -e "   ${YELLOW}source $CLAUDE_DIR/identity/env.sh${NC}"
}

# Get role-specific emoji and color
get_role_info() {
    local role="$1"
    case $role in
        "frontend") echo "🎨|#FF6B6B" ;;
        "backend") echo "⚙️|#4ECDC4" ;;
        "devops") echo "🚀|#45B7D1" ;;
        "fullstack") echo "🌟|#96CEB4" ;;
        "testing") echo "🧪|#FFEAA7" ;;
        "documentation") echo "📚|#DDA0DD" ;;
        *) echo "🤖|#95A5A6" ;;
    esac
}

# Register instance in global registry
register_instance() {
    local instance_id="$1"
    local name="$2"
    local role="$3"
    local specialty="$4"
    local emoji="$5"
    local color="$6"
    
    # Check if instance already exists
    if grep -q "id: \"$instance_id\"" "$CLAUDE_DIR/instances.yml" 2>/dev/null; then
        echo -e "${YELLOW}⚠️ Instance already registered, updating...${NC}"
        # Remove existing entry
        sed -i "/id: \"$instance_id\"/,+8d" "$CLAUDE_DIR/instances.yml"
    fi
    
    # Add to instances.yml
    cat >> "$CLAUDE_DIR/instances.yml" << EOF
- id: "$instance_id"
  name: "$name"
  role: "$role"
  specialty: "$specialty"
  emoji: "$emoji"
  color: "$color"
  github_prefix: "[$role-$name]"
  status: "active"
  created_at: "$(date -Iseconds)"
  last_seen: "$(date -Iseconds)"
EOF
    
    # Setup GitHub labels
    setup_github_labels "$role" "$name" "$color"
    
    # Log registration
    if command -v ./claude-coordinator.sh &> /dev/null; then
        ./claude-coordinator.sh audit_log "INSTANCE_REGISTERED" "$instance_id" "name=$name role=$role"
    fi
}

# Setup GitHub labels for role identification
setup_github_labels() {
    local role="$1"
    local name="$2"
    local color="$3"
    
    if command -v gh &> /dev/null; then
        # Remove # from color
        color="${color#\#}"
        
        # Create role-based label
        gh label create "claude:$role" --color "$color" --description "Claude $role instance" 2>/dev/null || true
        
        # Create instance-specific label
        gh label create "claude:$name" --color "$color" --description "Claude instance: $name" 2>/dev/null || true
        
        echo -e "${GREEN}✅ GitHub labels created for $name ($role)${NC}"
    fi
}

# Create default role tasks configuration
create_default_role_tasks() {
    cat > "$CLAUDE_DIR/role-tasks.yml" << 'EOF'
roles:
  frontend:
    description: "Frontend development and UI/UX"
    file_patterns:
      - "src/components/**"
      - "src/pages/**"
      - "src/styles/**"
      - "*.tsx"
      - "*.jsx"
      - "*.css"
      - "*.scss"
      - "*.vue"
    default_tasks:
      - "UI component development"
      - "Frontend testing"
      - "Responsive design"
      - "User interface improvements"
    keywords:
      - "component"
      - "styling"
      - "responsive"
      - "UI"
      - "frontend"
      
  backend:
    description: "Backend development and API"
    file_patterns:
      - "backend/**"
      - "api/**"
      - "server/**"
      - "*.py"
      - "*.js"
      - "*.sql"
      - "*.go"
      - "*.java"
    default_tasks:
      - "API development"
      - "Database operations"
      - "Backend testing"
      - "Authentication implementation"
    keywords:
      - "api"
      - "database"
      - "authentication"
      - "backend"
      - "server"
      
  devops:
    description: "DevOps and infrastructure"
    file_patterns:
      - ".github/workflows/**"
      - "docker/**"
      - "k8s/**"
      - "terraform/**"
      - "Dockerfile*"
      - "docker-compose*"
      - "*.yml"
      - "*.yaml"
    default_tasks:
      - "CI/CD pipeline"
      - "Infrastructure setup"
      - "Deployment automation"
      - "Monitoring configuration"
    keywords:
      - "deploy"
      - "docker"
      - "kubernetes"
      - "ci/cd"
      - "infrastructure"
      
  fullstack:
    description: "Full-stack development"
    file_patterns:
      - "src/**"
      - "backend/**"
      - "*.tsx"
      - "*.py"
      - "*.js"
    default_tasks:
      - "Full-stack feature development"
      - "End-to-end testing"
      - "Integration development"
    keywords:
      - "fullstack"
      - "integration"
      - "feature"
      
  testing:
    description: "Quality assurance and testing"
    file_patterns:
      - "tests/**"
      - "**/*.test.*"
      - "**/*.spec.*"
      - "cypress/**"
      - "e2e/**"
    default_tasks:
      - "Test automation"
      - "QA validation"
      - "Performance testing"
      - "Bug reproduction"
    keywords:
      - "test"
      - "spec"
      - "qa"
      - "bug"
      - "performance"
      
  documentation:
    description: "Documentation and guides"
    file_patterns:
      - "docs/**"
      - "*.md"
      - "README*"
      - "CHANGELOG*"
    default_tasks:
      - "Documentation writing"
      - "README updates"
      - "API documentation"
      - "User guides"
    keywords:
      - "docs"
      - "readme"
      - "documentation"
      - "guide"
      - "manual"
EOF
}

# Enhanced commit with identity
commit_with_identity() {
    local message="$1"
    shift
    local files=("$@")
    
    # Load current identity
    if [ -f "$CLAUDE_DIR/identity/current.json" ]; then
        local name=$(jq -r '.name' "$CLAUDE_DIR/identity/current.json")
        local role=$(jq -r '.role' "$CLAUDE_DIR/identity/current.json")
        local emoji=$(jq -r '.emoji' "$CLAUDE_DIR/identity/current.json")
        local github_prefix=$(jq -r '.github_prefix' "$CLAUDE_DIR/identity/current.json")
        local instance_id=$(jq -r '.instance_id' "$CLAUDE_DIR/identity/current.json")
        
        # Enhanced commit message
        local enhanced_message="${github_prefix} ${message}

${emoji} Claude Instance: $name ($role)
🤖 Automated commit via Claude Code
🆔 Instance ID: $instance_id
⏰ $(date)

Co-authored-by: Claude-$name <claude-$name@anthropic.com>"
        
        git add "${files[@]}" 2>/dev/null || git add .
        git commit -m "$enhanced_message"
        
        # Update last active time
        update_instance_activity
        
        echo -e "${GREEN}✅ Commit created with identity: ${github_prefix}${NC}"
    else
        echo -e "${YELLOW}⚠️ No identity configured, using standard commit${NC}"
        git add "${files[@]}" 2>/dev/null || git add .
        git commit -m "$message"
    fi
}

# Enhanced PR creation with identity
create_identity_pr() {
    local title="$1"
    local body="$2"
    local draft="${3:-true}"
    
    if [ -f "$CLAUDE_DIR/identity/current.json" ]; then
        local name=$(jq -r '.name' "$CLAUDE_DIR/identity/current.json")
        local role=$(jq -r '.role' "$CLAUDE_DIR/identity/current.json")
        local emoji=$(jq -r '.emoji' "$CLAUDE_DIR/identity/current.json")
        local specialty=$(jq -r '.specialty' "$CLAUDE_DIR/identity/current.json")
        local instance_id=$(jq -r '.instance_id' "$CLAUDE_DIR/identity/current.json")
        local github_prefix=$(jq -r '.github_prefix' "$CLAUDE_DIR/identity/current.json")
        
        # Enhanced PR title and body
        local enhanced_title="${github_prefix} ${title}"
        local enhanced_body="## ${emoji} Claude Instance Information

- **Name**: $name
- **Role**: $role
- **Specialty**: $specialty
- **Instance ID**: \`$instance_id\`
- **Created**: $(date)

## 📋 Description

$body

---

### 🏷️ Labels
<!-- Auto-apply labels -->
Labels: \`claude:$role\`, \`claude:$name\`

### 🤖 Automation Info
This PR was created by Claude Code instance **$name** specialized in **$role** development.  
**Instance Tracking**: \`$instance_id\`

🔧 Automated development via Claude Code AI Assistant."
        
        # Create PR with appropriate flags
        local pr_flags="--title \"$enhanced_title\" --body \"$enhanced_body\""
        
        if [ "$draft" = "true" ]; then
            pr_flags="--draft $pr_flags"
        fi
        
        # Add labels
        pr_flags="$pr_flags --label claude:$role --label claude:$name"
        
        # Execute PR creation
        eval "gh pr create $pr_flags"
        
        # Update instance activity
        update_instance_activity
        
        echo -e "${GREEN}✅ PR created with identity: ${github_prefix}${NC}"
        echo -e "${BLUE}🏷️ Applied labels: claude:$role, claude:$name${NC}"
    else
        echo -e "${YELLOW}⚠️ No identity configured, using standard PR creation${NC}"
        if [ "$draft" = "true" ]; then
            gh pr create --draft --title "$title" --body "$body"
        else
            gh pr create --title "$title" --body "$body"
        fi
    fi
}

# Update instance last activity time
update_instance_activity() {
    if [ -f "$CLAUDE_DIR/identity/current.json" ]; then
        local instance_id=$(jq -r '.instance_id' "$CLAUDE_DIR/identity/current.json")
        local current_time=$(date -Iseconds)
        
        # Update current identity file
        jq ".last_active = \"$current_time\"" "$CLAUDE_DIR/identity/current.json" > "$CLAUDE_DIR/identity/current.json.tmp"
        mv "$CLAUDE_DIR/identity/current.json.tmp" "$CLAUDE_DIR/identity/current.json"
        
        # Update instances registry
        if [ -f "$CLAUDE_DIR/instances.yml" ]; then
            sed -i "s/last_seen: .*/last_seen: \"$current_time\"/" "$CLAUDE_DIR/instances.yml"
        fi
    fi
}

# Show current identity status
show_identity_status() {
    if [ -f "$CLAUDE_DIR/identity/current.json" ]; then
        local identity=$(cat "$CLAUDE_DIR/identity/current.json")
        local name=$(echo "$identity" | jq -r '.name')
        local role=$(echo "$identity" | jq -r '.role')
        local emoji=$(echo "$identity" | jq -r '.emoji')
        local specialty=$(echo "$identity" | jq -r '.specialty')
        local instance_id=$(echo "$identity" | jq -r '.instance_id')
        local created_at=$(echo "$identity" | jq -r '.created_at')
        local last_active=$(echo "$identity" | jq -r '.last_active')
        
        echo -e "${BLUE}${ROBOT} Current Claude Identity${NC}"
        echo "========================="
        echo -e "${LABEL} Name: ${YELLOW}$name${NC} $emoji"
        echo -e "${CROWN} Role: ${YELLOW}$role${NC}"
        echo -e "${TOOLS} Specialty: ${YELLOW}$specialty${NC}"
        echo -e "🆔 Instance ID: ${BLUE}$instance_id${NC}"
        echo -e "📅 Created: $created_at"
        echo -e "⏰ Last Active: $last_active"
    else
        echo -e "${RED}❌ No identity configured${NC}"
        echo -e "${BLUE}Run: ./claude-identity.sh setup${NC}"
    fi
}

# List all registered instances
list_instances() {
    echo -e "${BLUE}${ROBOT} Registered Claude Instances${NC}"
    echo "==============================="
    
    if [ ! -f "$CLAUDE_DIR/instances.yml" ] || [ ! -s "$CLAUDE_DIR/instances.yml" ]; then
        echo -e "${YELLOW}No instances registered${NC}"
        return
    fi
    
    # Parse YAML and display instances (simplified)
    awk '
    /^- id:/ { 
        id = $2; gsub(/"/, "", id)
        getline; name = $2; gsub(/"/, "", name)
        getline; role = $2; gsub(/"/, "", role)
        getline; specialty = $2; gsub(/"/, "", specialty)
        getline; emoji = $2; gsub(/"/, "", emoji)
        printf "%-20s | %-12s | %s | %s\n", name " " emoji, role, id, specialty
    }
    ' "$CLAUDE_DIR/instances.yml" | sort
}

# Generate activity report
generate_activity_report() {
    local days="${1:-7}"
    local instance_name="$2"
    
    echo -e "${CHART} Claude Activity Report (Last $days days)"
    echo "============================================="
    
    if [ -n "$instance_name" ]; then
        # Instance-specific report
        echo -e "${BLUE}Instance: $instance_name${NC}"
        echo ""
        
        # Commits
        echo "📝 Commits:"
        git log --since="$days days ago" --grep="\[$instance_name\]" --pretty=format:"  %ad | %h | %s" --date=short | head -10
        
        echo ""
        echo ""
        echo "🔀 Pull Requests:"
        gh pr list --search "author:claude-$instance_name OR [$instance_name" --state all --limit 10 --json title,state,createdAt | \
        jq -r '.[] | "  \(.createdAt | split("T")[0]) | \(.state) | \(.title)"' 2>/dev/null || echo "  No PRs found"
    else
        # Overall report
        echo "📊 Overall Activity:"
        echo ""
        
        # Commits by role
        for role in frontend backend devops fullstack testing documentation; do
            local count=$(git log --since="$days days ago" --grep="\[$role-" --oneline | wc -l)
            if [ "$count" -gt 0 ]; then
                local emoji=$(get_role_info "$role" | cut -d'|' -f1)
                echo -e "  $emoji $role: $count commits"
            fi
        done
        
        echo ""
        echo "🔀 Recent PRs by Claude instances:"
        gh pr list --search "author:claude OR \[" --state all --limit 10 --json title,author,createdAt | \
        jq -r '.[] | "  \(.createdAt | split("T")[0]) | \(.title)"' 2>/dev/null || echo "  No PRs found"
    fi
}

# Role-based task assignment
assign_role_task() {
    local role="$1"
    
    if [ ! -f "$CLAUDE_DIR/role-tasks.yml" ]; then
        echo -e "${RED}❌ Role configuration not found${NC}"
        return 1
    fi
    
    echo -e "${BLUE}🎯 Assigning task for role: $role${NC}"
    
    # Get tasks for role (simplified YAML parsing)
    local tasks=$(awk "/^  $role:/,/^  [a-zA-Z]/" "$CLAUDE_DIR/role-tasks.yml" | grep "^      -" | head -5)
    
    if [ -z "$tasks" ]; then
        echo -e "${YELLOW}⚠️ No tasks configured for role: $role${NC}"
        return 1
    fi
    
    echo "Available tasks:"
    echo "$tasks" | nl -v1 -s". "
    
    read -p "Select task number (or press Enter for auto-assign): " task_choice
    
    if [ -z "$task_choice" ]; then
        # Auto-assign first task
        local selected_task=$(echo "$tasks" | head -1 | sed 's/^.*- //')
    else
        local selected_task=$(echo "$tasks" | sed -n "${task_choice}p" | sed 's/^.*- //')
    fi
    
    echo -e "${GREEN}✅ Assigned task: $selected_task${NC}"
    
    # Create task-specific branch
    local branch_name="$role/$(echo "$selected_task" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')"
    git checkout -b "$branch_name" 2>/dev/null || git checkout "$branch_name"
    
    echo -e "${BLUE}🌿 Created/switched to branch: $branch_name${NC}"
}

# Main command dispatcher
main() {
    case "${1:-status}" in
        "setup"|"init")
            init_identity_system
            setup_claude_identity "$2" "$3" "$4"
            ;;
        "status")
            show_identity_status
            ;;
        "list")
            list_instances
            ;;
        "commit")
            shift
            commit_with_identity "$@"
            ;;
        "pr")
            create_identity_pr "$2" "$3" "$4"
            ;;
        "assign-task")
            assign_role_task "$2"
            ;;
        "report")
            generate_activity_report "$2" "$3"
            ;;
        "update-activity")
            update_instance_activity
            ;;
        *)
            echo "Claude Code Identity & Role Management System"
            echo ""
            echo "Usage: $0 <command> [options]"
            echo ""
            echo "Commands:"
            echo "  setup [name] [role] [specialty]  Setup Claude identity"
            echo "  status                           Show current identity"
            echo "  list                            List all instances"
            echo "  commit <message> [files...]     Commit with identity"
            echo "  pr <title> <body> [draft]       Create PR with identity"
            echo "  assign-task <role>              Assign role-based task"
            echo "  report [days] [instance]        Generate activity report"
            echo "  update-activity                 Update last active time"
            echo ""
            echo "Examples:"
            echo "  $0 setup Alice frontend \"React,TypeScript,CSS\""
            echo "  $0 commit \"feat: add user component\""
            echo "  $0 pr \"Add user profile\" \"Implements user profile component\""
            echo "  $0 report 7 Alice"
            ;;
    esac
}

# Execute main function
main "$@"