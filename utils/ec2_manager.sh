#!/bin/bash
set -e

# ========================================
# EC2 Instance Manager (Terraform Wrapper)
# ========================================
# Usage:
#   ./ec2-manager.sh create     # Creates EC2 instance
#   ./ec2-manager.sh destroy    # Destroys EC2 instance
#   ./ec2-manager.sh plan       # Terraform plan only
#
# Prerequisites:
#   - AWS CLI configured (aws configure)
#   - Terraform installed
#   - Terraform config under ./terraform-ec2
# ========================================

TERRAFORM_DIR="terraform-ec2"

# --- Functions ---

check_aws() {
    echo "🔍 Checking AWS connectivity..."
    if ! aws sts get-caller-identity &>/dev/null; then
        echo "❌ AWS CLI not configured or credentials invalid."
        echo "   Run: aws configure"
        exit 1
    fi
    echo "✅ AWS CLI is configured as: $(aws sts get-caller-identity --query 'Arn' --output text)"
}

terraform_init() {
    echo "🚀 Initializing Terraform..."
    cd "$TERRAFORM_DIR"
    terraform init -upgrade -input=false
}

terraform_plan() {
    echo "📋 Running Terraform plan..."
    terraform plan
}

terraform_apply() {
    echo "⚙️  Applying Terraform plan..."
    terraform apply -auto-approve
    echo "✅ EC2 instance created successfully."
    echo "🌐 Public IP:"
    terraform output -raw public_ip || echo "(No output variable named 'public_ip')"
}

terraform_destroy() {
    echo "⚠️  This will destroy your EC2 instance!"
    read -p "Are you sure? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        terraform destroy -auto-approve
        echo "💥 EC2 instance destroyed."
    else
        echo "🛑 Operation canceled."
    fi
}

# --- Main ---

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 [create|destroy|plan]"
    exit 1
fi

ACTION="$1"

check_aws
terraform_init

case "$ACTION" in
    create)
        terraform_apply
        ;;
    destroy)
        terraform_destroy
        ;;
    plan)
        terraform_plan
        ;;
    *)
        echo "❌ Invalid action: $ACTION"
        echo "Usage: $0 [create|destroy|plan]"
        exit 1
        ;;
esac

cd - >/dev/null
