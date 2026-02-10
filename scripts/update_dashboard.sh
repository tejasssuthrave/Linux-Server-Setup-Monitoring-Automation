#!/bin/bash

# Paths
LOG_FILE="/home/ec2-user/server_stats.csv"
HTML_FILE="/var/www/html/index.html"

# Ensure CSV exists
if [ ! -f $LOG_FILE ]; then
    echo "timestamp,cpu,mem,disk" > $LOG_FILE
fi

# Get real stats
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
MEM=$(free | awk '/Mem:/ {printf("%.2f", $3/$2 * 100)}')
DISK=$(df / | awk 'NR==2 {gsub("%",""); print $5}')

# Log data with timestamp
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
echo "$TIMESTAMP,$CPU,$MEM,$DISK" >> $LOG_FILE

# Keep last 20 records
tail -n 20 $LOG_FILE > /home/ec2-user/server_stats_tail.csv

# Read CSV into JS arrays
LABELS=$(awk -F, 'NR>1{print "\""$1"\""}' /home/ec2-user/server_stats_tail.csv | paste -sd,)
CPU_DATA=$(awk -F, 'NR>1{print $2}' /home/ec2-user/server_stats_tail.csv | paste -sd,)
MEM_DATA=$(awk -F, 'NR>1{print $3}' /home/ec2-user/server_stats_tail.csv | paste -sd,)
DISK_DATA=$(awk -F, 'NR>1{print $4}' /home/ec2-user/server_stats_tail.csv | paste -sd,)

# Generate HTML
cat <<EOL > $HTML_FILE
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Linux Server Dashboard</title>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<style>
body { font-family: Arial; background-color: #f5f5f5; text-align: center; margin:0; padding:0;}
header { background: #2c3e50; color: white; padding: 20px; }
section { margin: 20px auto; padding: 20px; background: white; border-radius: 10px; max-width: 900px; }
footer { margin-top: 20px; padding: 20px; background: #2c3e50; color: white; }
.chart-container { display: flex; justify-content: space-between; flex-wrap: wrap; }
.chart-container canvas { width: 32% !important; height: 250px !important; margin-bottom: 20px; }
.status-box { display: inline-block; margin: 10px; padding: 15px 25px; border-radius: 10px; color: white; font-weight: bold; min-width: 150px; }
.status-green { background-color: #28a745; }
.status-yellow { background-color: #ffc107; color: black; }
.status-red { background-color: #dc3545; }
</style>
<meta http-equiv="refresh" content="60">
</head>
<body>

<header>
<h1>Linux Server Setup & Monitoring</h1>
</header>

<section>
<h2>Project Overview</h2>
<p>This server is configured to run Apache, monitor system resources, and automate tasks using shell scripts and cron jobs.</p>
</section>

<section>
<h2>Automation & Monitoring</h2>
<p>Latest System Stats:</p>
<div id="status-container">
  <span id="cpuStatus" class="status-box">CPU: ${CPU}%</span>
  <span id="memStatus" class="status-box">Memory: ${MEM}%</span>
  <span id="diskStatus" class="status-box">Disk: ${DISK}%</span>
</div>
<p>Disk usage is automatically logged hourly using a shell script and cron job.</p>
</section>

<section>
<h2>System Resource Usage (Last 20 Records)</h2>
<div class="chart-container">
<canvas id="cpuChart"></canvas>
<canvas id="memChart"></canvas>
<canvas id="diskChart"></canvas>
</div>
</section>

<footer>
<p>Project by Tejas S Suthrave | February 2026</p>
</footer>

<script>
// JS arrays for charts
const labels = [${LABELS}];
const cpuData = [${CPU_DATA}];
const memData = [${MEM_DATA}];
const diskData = [${DISK_DATA}];

// Charts
new Chart(document.getElementById('cpuChart'), {
    type: 'line',
    data: { labels: labels, datasets: [{ label: 'CPU %', data: cpuData, borderColor: 'blue', fill: false }] },
    options: { scales: { y: { min:0, max:100 } } }
});
new Chart(document.getElementById('memChart'), {
    type: 'line',
    data: { labels: labels, datasets: [{ label: 'Memory %', data: memData, borderColor: 'purple', fill: false }] },
    options: { scales: { y: { min:0, max:100 } } }
});
new Chart(document.getElementById('diskChart'), {
    type: 'line',
    data: { labels: labels, datasets: [{ label: 'Disk %', data: diskData, borderColor: 'red', fill: false }] },
    options: { scales: { y: { min:0, max:100 } } }
});

// Update status colors
function updateStatus(id, value) {
    const elem = document.getElementById(id);
    if(value < 70) { elem.className = "status-box status-green"; }
    else if(value < 85) { elem.className = "status-box status-yellow"; }
    else { elem.className = "status-box status-red"; }
}

// Convert string to float
updateStatus("cpuStatus", parseFloat(${CPU}));
updateStatus("memStatus", parseFloat(${MEM}));
updateStatus("diskStatus", parseFloat(${DISK}));
</script>

</body>
</html>
EOL
