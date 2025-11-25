const Url = require('../models/Url');

exports.shortenUrl = async (req, res) => {
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

    try {
        // Generate short ID
        let shortId = Math.random().toString(36).substr(2, 6);

        // Check if shortId already exists (unlikely but possible)
        let existingUrl = await Url.findOne({ shortId });
        while (existingUrl) {
            shortId = Math.random().toString(36).substr(2, 6);
            existingUrl = await Url.findOne({ shortId });
        }

        // Save to database
        const newUrl = new Url({
            shortId,
            originalUrl: url
        });
        await newUrl.save();

        // Build the public short URL using FRONTEND_URL when available.
        // FRONTEND_URL is set in production (terraform) to the ALB domain; locally it falls back to the request host.
        const base = process.env.FRONTEND_URL || `${req.protocol}://${req.get('host')}`;
        const shortUrl = `${base.replace(/\/$/, '')}/${shortId}`;
        res.json({ shortUrl });
    } catch (error) {
        res.status(500).json({ error: 'Server error' });
    }
};

exports.redirectUrl = async (req, res) => {
    const { shortId } = req.params;

    try {
        const urlDoc = await Url.findOne({ shortId });

        if (urlDoc) {
            res.redirect(urlDoc.originalUrl);
        } else {
            res.status(404).send('Short URL not found');
        }
    } catch (error) {
        res.status(500).send('Server error');
    }
};

exports.getHistory = async (req, res) => {
    try {
        const urls = await Url.find()
            .sort({ createdAt: -1 })
            .limit(10)
            .select('shortId originalUrl createdAt');

        const base = process.env.FRONTEND_URL || `${req.protocol}://${req.get('host')}`;
        const history = urls.map(url => ({
            shortUrl: `${base.replace(/\/$/, '')}/${url.shortId}`,
            originalUrl: url.originalUrl,
            createdAt: url.createdAt
        }));

        res.json({ history });
    } catch (error) {
        res.status(500).json({ error: 'Server error' });
    }
};