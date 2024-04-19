
# Functionality

- The script performs the following tasks:
- Website List
- DNS Resolution
- AD Membership Check
- Website Monitoring (Optional)
- Logging

# Security Considerations:

- The provided version stores sensitive information ***(AD domain name and container)*** securely in a separate ***file (website_monitor.cfg).***
- This file is encrypted using a user-provided password during the first script execution.

# Using the Script

- Clone the Repository
- Configuration:
- Update the ***website_monitor.cfg file*** with your AD domain name and container name ***(secure the password during first run).***
- Modify the ***websites.txt file*** to include website URLs you want to monitor.
- ***(Optional) Customize the Test-Website function for your specific monitoring needs.***
-  Execute the script using PowerShell.
