# Architecture

This project deploys a three-tier AWS application architecture for the `deployment-notes` sample app. The stack is intentionally realistic enough to demonstrate infrastructure engineering skills while remaining disposable for portfolio use.

## Request Flow

```text
User
  -> Cloudflare DNS
  -> Public Application Load Balancer
  -> Web EC2 Auto Scaling Group
  -> Internal Application Load Balancer
  -> App EC2 Auto Scaling Group
  -> RDS MySQL
```

The public ALB terminates HTTPS and forwards traffic to the web tier. The web tier serves the Vue frontend through Nginx and proxies API requests to the internal ALB. The internal ALB forwards API traffic to the Flask backend running in the app tier. The backend connects to a private RDS MySQL database.

## Network Layout

The VPC is split into four subnet groups across multiple Availability Zones:

- Public subnets for the internet gateway, NAT gateways, and public ALB.
- Web private subnets for frontend EC2 instances.
- App private subnets for backend EC2 instances and the internal ALB.
- Database private subnets for RDS.

The database route table does not include a NAT route. Web and app private subnets use NAT gateways for outbound access to AWS APIs, ECR, SSM, CloudWatch, and package/image downloads.

## Tier Boundaries

Security groups enforce tier-to-tier access:

- Internet traffic reaches only the public ALB on HTTP/HTTPS.
- The public ALB reaches only the web EC2 security group.
- Web EC2 instances reach the internal ALB.
- The internal ALB reaches only the app EC2 security group.
- App EC2 instances reach the RDS security group on the database port.

This keeps direct access to application instances and RDS private.

## DNS

Public DNS is managed in Cloudflare as a CNAME pointing to the public ALB. Private application routing uses a Route 53 private hosted zone for the internal API name.

The Terraform output `public_application_url` is constructed from the configured public record and public zone name.

The public ALB uses an existing ACM certificate. The certificate must be issued in the same AWS region as the ALB and must cover the final public hostname, such as `www.example.com`. This Terraform stack does not create or validate the certificate.

If Cloudflare proxying is enabled for the public record, test the full request path carefully. Cloudflare's proxy mode changes how clients connect to the origin and can hide direct DNS behavior during debugging. For certificate issuance or renewal, make sure any required DNS validation records remain visible and are not accidentally proxied.

## Diagram

The root README includes the main architecture diagram:

![Architecture diagram](../Architecture.png)
