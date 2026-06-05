data "aws_route53_zone" "main" {
  name = var.domain_name
}

resource "aws_ses_domain_identity" "main" {
  domain = var.domain_name
}

resource "aws_ses_domain_dkim" "main" {
  domain = aws_ses_domain_identity.main.domain
}

resource "aws_ses_domain_mail_from" "main" {
  domain           = aws_ses_domain_identity.main.domain
  mail_from_domain = "mail.${var.domain_name}"
}

# Domain verification TXT record
resource "aws_route53_record" "ses_verification" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "_amazonses.${var.domain_name}"
  type    = "TXT"
  ttl     = 600
  records = [aws_ses_domain_identity.main.verification_token]
}

# DKIM CNAME records
resource "aws_route53_record" "ses_dkim" {
  count   = 3
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "${aws_ses_domain_dkim.main.dkim_tokens[count.index]}._domainkey.${var.domain_name}"
  type    = "CNAME"
  ttl     = 600
  records = ["${aws_ses_domain_dkim.main.dkim_tokens[count.index]}.dkim.amazonses.com"]
}

# MAIL FROM MX record
resource "aws_route53_record" "ses_mail_from_mx" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "mail.${var.domain_name}"
  type    = "MX"
  ttl     = 600
  records = ["10 feedback-smtp.${var.aws_region}.amazonses.com"]
}

# MAIL FROM SPF record
resource "aws_route53_record" "ses_mail_from_spf" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "mail.${var.domain_name}"
  type    = "TXT"
  ttl     = 600
  records = ["v=spf1 include:amazonses.com ~all"]
}

resource "aws_ses_domain_identity_verification" "main" {
  domain     = aws_ses_domain_identity.main.id
  depends_on = [aws_route53_record.ses_verification]
}

resource "aws_ses_template" "availability_alert" {
  name    = "overland-track-availability-alert"
  subject = "🏔️ Overland Track Availability Alert"
  html    = <<-EOT
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Overland Track Availability Alert</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f8f9fa;
        }
        .container {
            background: white;
            border-radius: 12px;
            padding: 30px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            border: 1px solid #e9ecef;
        }
        .header {
            text-align: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 2px solid #55437e;
        }
        .header h1 {
            color: #55437e;
            font-size: 28px;
            margin: 0;
            font-weight: 700;
        }
        .alert-box {
            background: linear-gradient(135deg, #d4edda, #c3e6cb);
            border: 1px solid #c3e6cb;
            border-radius: 8px;
            padding: 20px;
            margin: 20px 0;
            text-align: center;
        }
        .alert-box h2 {
            color: #155724;
            margin: 0 0 10px 0;
            font-size: 22px;
        }
        .details {
            background: #f8f9fa;
            border-radius: 8px;
            padding: 20px;
            margin: 20px 0;
        }
        .details h3 {
            color: #55437e;
            margin-top: 0;
            font-size: 18px;
        }
        .detail-item {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid #e9ecef;
        }
        .detail-item:last-child {
            border-bottom: none;
        }
        .detail-label {
            font-weight: 600;
            color: #495057;
        }
        .detail-value {
            color: #28a745;
            font-weight: 600;
        }
        .cta-button {
            display: inline-block;
            background: linear-gradient(135deg, #28a745, #20c997);
            color: white;
            text-decoration: none;
            padding: 15px 30px;
            border-radius: 8px;
            font-weight: 600;
            font-size: 16px;
            text-align: center;
            margin: 20px 0;
            transition: all 0.2s ease;
        }
        .footer {
            text-align: center;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #e9ecef;
            color: #6c757d;
            font-size: 14px;
        }
        .footer a {
            color: #55437e;
            text-decoration: none;
        }
        @media (max-width: 600px) {
            body {
                padding: 10px;
            }
            .container {
                padding: 20px;
            }
            .detail-item {
                flex-direction: column;
                gap: 5px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🏔️ Overland Track</h1>
        </div>
        
        <div class="alert-box">
            <h2>🎉 Availability Alert!</h2>
            <p>Great news! Spots have become available for your requested dates.</p>
        </div>
        
        <div class="details">
            <h3>Booking Details</h3>
            <div class="detail-item">
                <span class="detail-label">Date:&nbsp;</span>
                <span class="detail-value">{{date}}</span>
            </div>
            <div class="detail-item">
                <span class="detail-label">Availability:&nbsp;</span>
                <span class="detail-value">{{availability}}</span>
            </div>
        </div>
        
        <div style="text-align: center;">
            <a href="https://azapps.customlinc.com.au/tasparksoverland/BookingCat/Availability/?Category=OVERLAND" class="cta-button">
                Book Now
            </a>
        </div>
        
        <div class="footer">
            <p>This alert was sent because you requested notifications for Overland Track availability.</p>
            <p>Manage your alerts at <a href="https://overlandtrackavailability.com/dashboard">overlandtrackavailability.com</a></p>
        </div>
    </div>
</body>
</html>
EOT
  text    = <<-EOT
Overland Track Availability Alert

Great news! Spots have become available for your requested dates.

Booking Details:
- Date: {{date}}
- Availability: {{availability}}

Book now: https://azapps.customlinc.com.au/tasparksoverland/BookingCat/Availability/?Category=OVERLAND

This alert was sent because you requested notifications for Overland Track availability.
Manage your alerts at https://overlandtrackavailability.com/dashboard
EOT
}
