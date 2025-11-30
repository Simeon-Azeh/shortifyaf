require('dotenv').config();
const express = require('express');
const db = require('./db');
const swaggerJsdoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

// CORS configuration - allow frontend origin and localhost for development
const allowedOrigins = [
    process.env.FRONTEND_URL,
    'http://localhost:5173',
    'http://127.0.0.1:5173',
    // Allow the public IP if it's set
    process.env.FRONTEND_URL ? process.env.FRONTEND_URL.replace('http://', '').split(':')[0] : null,
].filter(Boolean);

app.use(cors({
    origin: function (origin, callback) {
        // Allow requests with no origin (like mobile apps or curl requests)
        if (!origin) return callback(null, true);

        if (allowedOrigins.includes(origin) || allowedOrigins.some(allowed => origin.includes(allowed))) {
            return callback(null, true);
        }

        console.log('CORS blocked origin:', origin);
        console.log('Allowed origins:', allowedOrigins);
        return callback(new Error('Not allowed by CORS'));
    },
    credentials: true
}));

// Swagger definition
const swaggerOptions = {
    definition: {
        openapi: '3.0.0',
        info: {
            title: 'ShortifyAF API',
            version: '1.0.0',
            description: 'A simple URL shortener API for Africa\'s digital ecosystem',
        },
        // The API routes are mounted under `/api`, so include `/api` in the server URL
        servers: [
            {
                url: `http://localhost:${PORT}/api`,
            },
        ],
    },
    apis: ['./routes/*.js'], // paths to files containing OpenAPI definitions
};

const swaggerSpecs = swaggerJsdoc(swaggerOptions);

// Initialize PostgreSQL (create tables if needed)
db.init().then(() => {
    console.log('Postgres DB ready');
}).catch(err => {
    console.error('Postgres connection error:', err);
});

app.use(express.json());

// Swagger UI
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpecs));

// Routes
const urlRoutes = require('./routes/urlRoutes');
app.use('/api', urlRoutes);

// Redirect route for short URLs
const urlController = require('./controllers/urlController');
app.get('/:shortId', urlController.redirectUrl);

// Basic route
app.get('/', (req, res) => {
    res.send('Welcome to ShortifyAF - A simple URL shortener for Africa');
});

// Only start the server if this file is run directly (not when required as a module)
if (require.main === module) {
    app.listen(PORT, () => {
        console.log(`Server running on port ${PORT}`);
        console.log(`API Documentation available at http://localhost:${PORT}/api-docs`);
    });
}

// Export the app for testing
module.exports = app;