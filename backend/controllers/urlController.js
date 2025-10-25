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
        const shortId = Math.random().toString(36).substr(2, 6);

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

        const shortUrl = `http://localhost:${process.env.PORT || 3000}/${shortId}`;
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