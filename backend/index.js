const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// In-memory storage for URLs
const urlStore = {};

// Basic route
app.get('/', (req, res) => {
    res.send('Welcome to ShortifyAF - A simple URL shortener for Africa');
});

// POST /shorten - Shorten a URL
app.post('/shorten', (req, res) => {
    const { url } = req.body;

    // Basic validation
    if (!url) {
        return res.status(400).json({ error: 'URL is required' });
    }

    try {
        new URL(url); // Validate URL format
    } catch (err) {
        return res.status(400).json({ error: 'Invalid URL format' });
    }

    // Generate short code
    const shortCode = Math.random().toString(36).substr(2, 6);
    urlStore[shortCode] = url;

    const shortUrl = `http://localhost:${PORT}/${shortCode}`;
    res.json({ shortUrl });
});

// GET /:shortCode - Redirect to original URL
app.get('/:shortCode', (req, res) => {
    const { shortCode } = req.params;
    const longUrl = urlStore[shortCode];

    if (longUrl) {
        res.redirect(longUrl);
    } else {
        res.status(404).send('Short URL not found');
    }
});

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});