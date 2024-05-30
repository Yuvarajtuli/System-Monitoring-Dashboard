const express = require('express');
const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');

const app = express();
const port = 3000;

// Serve static files from the 'public' directory
app.use(express.static(path.join(__dirname, 'public')));

// Endpoint to get system metrics
app.get('/api/metrics', (req, res) => {
  const scriptPath = path.join(__dirname, 'scripts', 'system.sh');
  exec(scriptPath, (error, stdout, stderr) => {
    if (error) {
      console.error(`exec error: ${error}`);
      return res.status(500).send('Internal Server Error');
    }
    const metricsFilePath = path.join(__dirname, 'data', 'metrics.json');
    
    fs.readFile(metricsFilePath, 'utf8', (err, data) => {
      if (err) {
        console.error(`readFile error: ${err}`);
        return res.status(500).send('Internal Server Error');
      }
      res.setHeader('Content-Type', 'application/json');
      res.send(data);
    });
  });
});

app.get('/api/logs', (req, res) => {
  const scriptPath = path.join(__dirname, 'scripts', 'jobs.sh');
  exec(scriptPath, (error, stdout, stderr) => {
    if (error) {
      console.error(`exec error: ${error}`);
      return res.status(500).send('Internal Server Error');
    }
    const logFilePath = path.join(__dirname, 'data', 'system_jobs.json');
    fs.readFile(logFilePath, 'utf8', (err, data) => {
      if (err) {
        console.error(`readFile error: ${err}`);
        return res.status(500).send('Internal Server Error');
      }
      res.setHeader('Content-Type', 'application/json');
      res.send(data);
    });
  });
});

app.get('/metrics', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'metrics.html'));
});
app.get('/logs', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'logs.html'));
});
// Start the server
app.listen(port, () => {
  console.log(`Server is running at http://localhost:${port}`);
});
