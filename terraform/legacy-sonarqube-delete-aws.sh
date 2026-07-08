#!/usr/bin/env bash
set -euo pipefail
STATE_JSON="/tmp/sonarqube-old-state.json"
aws s3 cp "s3://react-js-application-terraform-state-866934333672/react-js-application/sonarqube/terraform.tfstate" "$STATE_JSON" --only-show-errors
mapfile -t VALUES < <(node - <<'NODE' "$STATE_JSON"
const fs=require('fs');
const s=JSON.parse(fs.readFileSync(process.argv[2],'utf8'));
let out={instanceId:'',sgId:'',vpcId:'',iamProfile:'',iamRole:'',publicSubnets:[],privateSubnets:[]};
for (const r of s.resources||[]) {
  for (const i of r.instances||[]) {
    const a=i.attributes||{};
    const key=`${r.type}.${r.name}`;
    if (key==='aws_instance.this') out.instanceId=a.id||'';
    if (key==='aws_security_group.sonarqube') out.sgId=a.id||'';
    if (key==='aws_vpc.main') out.vpcId=a.id||'';
    if (key==='aws_subnet.public' && a.id) out.publicSubnets.push(a.id);
    if (key==='aws_subnet.private_app' && a.id) out.privateSubnets.push(a.id);
    if (key==='aws_iam_instance_profile.this') out.iamProfile=a.name||'';
    if (key==='aws_iam_role.this') out.iamRole=a.name||'';
  }
}
console.log(out.instanceId);
console.log(out.sgId);
console.log(out.vpcId);
console.log(out.iamProfile);
console.log(out.iamRole);
console.log(out.publicSubnets.join(' '));
console.log(out.privateSubnets.join(' '));
NODE
)
INSTANCE_ID="${VALUES[0]}"
SG_ID="${VALUES[1]}"
VPC_ID="${VALUES[2]}"
IAM_PROFILE="${VALUES[3]}"
IAM_ROLE="${VALUES[4]}"
PUBLIC_SUBNETS="${VALUES[5]}"
PRIVATE_SUBNETS="${VALUES[6]}"

if [[ -n "$INSTANCE_ID" ]]; then
  aws ec2 terminate-instances --region us-east-1 --instance-ids "$INSTANCE_ID" --output json >/dev/null
  aws ec2 wait instance-terminated --region us-east-1 --instance-ids "$INSTANCE_ID"
fi

if [[ -n "$IAM_PROFILE" && -n "$IAM_ROLE" ]]; then
  aws iam remove-role-from-instance-profile --instance-profile-name "$IAM_PROFILE" --role-name "$IAM_ROLE" >/dev/null 2>&1 || true
  aws iam delete-instance-profile --instance-profile-name "$IAM_PROFILE" >/dev/null 2>&1 || true
fi

if [[ -n "$IAM_ROLE" ]]; then
  aws iam detach-role-policy --role-name "$IAM_ROLE" --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore >/dev/null 2>&1 || true
  aws iam delete-role --role-name "$IAM_ROLE" >/dev/null 2>&1 || true
fi

if [[ -n "$VPC_ID" ]]; then
  IGWS=$(aws ec2 describe-internet-gateways --region us-east-1 --filters Name=attachment.vpc-id,Values="$VPC_ID" --query 'InternetGateways[].InternetGatewayId' --output text)
  for IGW in $IGWS; do
    aws ec2 detach-internet-gateway --region us-east-1 --internet-gateway-id "$IGW" --vpc-id "$VPC_ID" >/dev/null 2>&1 || true
    aws ec2 delete-internet-gateway --region us-east-1 --internet-gateway-id "$IGW" >/dev/null 2>&1 || true
  done

  RTBS=$(aws ec2 describe-route-tables --region us-east-1 --filters Name=vpc-id,Values="$VPC_ID" --query 'RouteTables[?Associations[?Main!=`true`]].RouteTableId' --output text)
  for RTB in $RTBS; do
    ASSOCS=$(aws ec2 describe-route-tables --region us-east-1 --route-table-ids "$RTB" --query 'RouteTables[0].Associations[?Main!=`true`].RouteTableAssociationId' --output text)
    for ASSOC in $ASSOCS; do
      aws ec2 disassociate-route-table --region us-east-1 --association-id "$ASSOC" >/dev/null 2>&1 || true
    done
    aws ec2 delete-route-table --region us-east-1 --route-table-id "$RTB" >/dev/null 2>&1 || true
  done
fi

if [[ -n "$SG_ID" ]]; then
  aws ec2 delete-security-group --region us-east-1 --group-id "$SG_ID" >/dev/null 2>&1 || true
fi

for SUBNET in $PRIVATE_SUBNETS $PUBLIC_SUBNETS; do
  [[ -n "$SUBNET" ]] || continue
  aws ec2 delete-subnet --region us-east-1 --subnet-id "$SUBNET" >/dev/null 2>&1 || true
done

if [[ -n "$VPC_ID" ]]; then
  aws ec2 delete-vpc --region us-east-1 --vpc-id "$VPC_ID" >/dev/null 2>&1 || true
fi

aws s3 rm "s3://react-js-application-terraform-state-866934333672/react-js-application/sonarqube/terraform.tfstate" --only-show-errors
printf 'Legacy SonarQube standalone cleanup attempted for VPC %s\n' "$VPC_ID"
