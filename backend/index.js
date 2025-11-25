require('dotenv').config();
const express = require('express');
const db = require('./db');
const swaggerJsdoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

// CORS configuration
app.use(cors({
    origin: process.env.FRONTEND_URL || 'http://localhost:5173',
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
        servers: [
            {
                url: `http://localhost:${PORT}`,
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