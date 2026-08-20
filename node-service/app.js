const express = require('express');
const axios = require('axios');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Service URLs from environment or defaults
const JAVA_URL = process.env.JAVA_SERVICE_URL || 'http://java-service:8080';
const PYTHON_URL = process.env.PYTHON_SERVICE_URL || 'http://python-service:5000';

// Serve static frontend
app.use(express.static(path.join(__dirname, 'public')));

// Health endpoint
app.get('/health', (req, res) => {
    res.send('Service is running');
});

// Connectivity check endpoint
app.get('/check/:target', async (req, res) => {
    const { target } = req.params;
    let url, targetName;

    if (target === 'java') {
        url = `${JAVA_URL}/health`;
        targetName = 'Java';
    } else if (target === 'python') {
        url = `${PYTHON_URL}/health`;
        targetName = 'Python';
    } else {
        return res.json({ status: 'Not Connected', target, message: 'Unknown service' });
    }

    try {
        const response = await axios.get(url, { timeout: 3000 });
        if (response.data === 'Service is running') {
            res.json({ status: 'Connected', target: targetName, message: '✅ OK' });
        } else {
            res.json({ status: 'Not Connected', target: targetName, message: '❌ Unexpected response' });
        }
    } catch (error) {
        res.json({ status: 'Not Connected', target: targetName, message: '❌ Unreachable or timeout' });
    }
});

app.listen(PORT, () => {
    console.log(`Node service running on port ${PORT}`);
});