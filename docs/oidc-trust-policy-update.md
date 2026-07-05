# GitHub OIDC Trust Policy Update

The workflows use GitHub OIDC and assume this role:

```text
arn:aws:iam::866934333672:role/react-js-application-github-actions-bootstrap-role
```

The workflows include:

```yaml
permissions:
  id-token: write
  contents: read
```

For the production approval gate, the `apply-prod` job uses:

```yaml
environment: prod
```

That means the IAM role trust policy must allow both branch-based and environment-based GitHub OIDC subjects.

Replace `<GITHUB_ORG_OR_USER>` and `<REPO_NAME>` with your exact GitHub owner and repository name.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowGitHubActionsOIDC",
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::866934333672:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": [
            "repo:<GITHUB_ORG_OR_USER>/<REPO_NAME>:ref:refs/heads/dev",
            "repo:<GITHUB_ORG_OR_USER>/<REPO_NAME>:ref:refs/heads/uat",
            "repo:<GITHUB_ORG_OR_USER>/<REPO_NAME>:ref:refs/heads/prod",
            "repo:<GITHUB_ORG_OR_USER>/<REPO_NAME>:pull_request",
            "repo:<GITHUB_ORG_OR_USER>/<REPO_NAME>:environment:prod"
          ]
        }
      }
    }
  ]
}
```

Only the production apply job uses a GitHub Environment approval gate. Dev and UAT apply jobs do not use a GitHub Environment, so they continue to use branch-based OIDC subjects.
