# Function to assume AWS role. Credentials to assume have to already exist

function assume_aws_role {
    # Assume a role based on the currently used credentials
    ASSUME_ROLE=$1
    CURRENT_ROLE=$(aws sts get-caller-identity)

    if [ $? -ne 0 ]; then
        error No valid credentials
        return
    fi
    info Current role ${CURRENT_ROLE}

    STS=($(aws sts assume-role \
        --role-arn ${ASSUME_ROLE} \
        --role-session-name "assumed-session" \
        --duration-seconds 3600 \
        --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken,Expiration]' \
        --output text))

    if [ $? -ne 0 ]; then
        error "Assuming role ${ASSUME_ROLE} failed"
        return
    fi

    export AWS_ACCESS_KEY_ID="${STS[0]}"
    export AWS_SECRET_ACCESS_KEY="${STS[1]}"
    export AWS_SESSION_TOKEN="${STS[2]}"
    export AWS_SESSION_EXPIRATION="${STS[3]}"
    info "Assumed role $(aws sts get-caller-identity)"
    info "Session expires at ${AWS_SESSION_EXPIRATION}"
}
