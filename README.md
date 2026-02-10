# Linux Server Setup & Monitoring

This project demonstrates a Linux server setup with automated monitoring of CPU, Memory, and Disk usage, along with a live dashboard for visualization.

---

## **Project Overview**

- Apache server configured on Linux (AWS EC2 instance)
- System resource monitoring: CPU, Memory, Disk
- Automated logging using shell scripts and cron jobs
- Dashboard created using Chart.js to visualize the last 20 records
- Color-coded alerts for CPU, Memory, and Disk usage

---

## **Features**

1. **Automation & Monitoring**
   - Disk, CPU, and Memory usage logged automatically
   - Cron job updates the dashboard every minute
   - Latest stats displayed in color-coded boxes:
     - Green: Normal (<70%)
     - Yellow: Moderate (70–85%)
     - Red: High (>85%)

2. **Dashboard**
   - Live line charts for CPU, Memory, Disk usage
   - Auto-refresh every minute
   - Shows last 20 records for quick trend analysis

3. **Scripts**
   - `update_dashboard.sh` → main shell script for logging stats and generating the dashboard

---

## **How to Use**

1. **Upload scripts to your Linux server (e.g., AWS EC2).**  
2. **Make the script executable:**

chmod +x scripts/update_dashboard.sh

4. **Run the script manually to test:**

./scripts/update_dashboard.sh


4. **Setup Cron Job for automation:**
crontab -e

* * * * * /home/ubuntu/linux-server-dashboard/scripts/update_dashboard.sh

5. **Open the dashboard in your browser:**

http://*<your-ec2-public-ip>*/

---
## Dependencies
- Linux server (Ubuntu, Amazon Linux, etc.)
- Apache server installed and running
- bash, awk, df, top, free (standard Linux utilities)
- Internet access to load Chart.js from CDN

