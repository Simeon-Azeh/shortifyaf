const express = require('express');
const router = express.Router();
const urlController = require('../controllers/urlController');

/**
 * @swagger
 * /shorten:
 *   post:
 *     summary: Shorten a URL
 *     description: Takes a long URL and returns a shortened version
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               url:
 *                 type: string
 *                 description: The original URL to shorten
 *                 example: https://example.com/very/long/url
 *     responses:
 *       200:
 *         description: Successfully shortened URL
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 shortUrl:
 *                   type: string
 *                   example: http://localhost:3000/abc123
 *       400:
 *         description: Invalid URL or missing URL
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 error:
 *                   type: string
 *                   example: URL is required
 *       500:
 *         description: Server error
 */
router.post('/shorten', urlController.shortenUrl);

/**
 * @swagger
 * /history:
 *   get:
 *     summary: Get URL shortening history
 *     description: Returns the last 10 shortened URLs with their original and short versions
 *     responses:
 *       200:
 *         description: Successfully retrieved history
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 history:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       shortUrl:
 *                         type: string
 *                         example: http://localhost:3000/abc123
 *                       originalUrl:
 *                         type: string
 *                         example: https://example.com/very/long/url
 *                       createdAt:
 *                         type: string
 *                         format: date-time
 *                         example: 2023-10-25T10:00:00.000Z
 *       500:
 *         description: Server error
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 error:
 *                   type: string
 *                   example: Server error
 */
router.get('/history', urlController.getHistory);

/**
 * @swagger
 * /{shortId}:
 *   get:
 *     summary: Redirect to original URL
 *     description: Redirects to the original URL based on the short ID
 *     parameters:
 *       - in: path
 *         name: shortId
 *         required: true
 *         schema:
 *           type: string
 *         description: The short ID of the URL
 *         example: abc123
 *     responses:
 *       302:
 *         description: Redirect to original URL
 *       404:
 *         description: Short URL not found
 *         content:
 *           text/plain:
 *             schema:
 *               type: string
 *               example: Short URL not found
 *       500:
 *         description: Server error
 */
router.get('/:shortId', urlController.redirectUrl);

module.exports = router;