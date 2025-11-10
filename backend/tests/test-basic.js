const http = require('http');

// Basic test to ensure the server can start and respond
async function testServer() {
    console.log(' Running basic server tests...');

    throw new Error("Intentional CI failure for evidence");


    try {
        // Test 1: Check if we can require the main module without errors
        console.log('Test 1: Module loading...');
        const app = require('../index.js');
        console.log(' Module loaded successfully');

        // Test 2: Check if server can start 
        console.log(' Test 2: Server startup...');
        const PORT = 3002; // Use a different port for testing

        const server = app.listen(PORT, () => {
            console.log(`Server started on port ${PORT}`);
        });

        // Give server time to start
        await new Promise(resolve => setTimeout(resolve, 1000));

        // Test 3: Make a basic HTTP request to the server
        console.log(' Test 3: HTTP request...');
        const response = await new Promise((resolve, reject) => {
            const req = http.get(`http://localhost:${PORT}/`, (res) => {
                let data = '';
                res.on('data', chunk => data += chunk);
                res.on('end', () => resolve({ status: res.statusCode, data }));
            });
            req.on('error', reject);
            req.setTimeout(5000, () => reject(new Error('Request timeout')));
        });

        if (response.status === 200 && response.data.includes('ShortifyAF')) {
            console.log(' HTTP request successful');
        } else {
            throw new Error(`Unexpected response: ${response.status} - ${response.data}`);
        }

        // Clean up
        server.close(() => {
            console.log(' Server closed successfully');
        });

        console.log(' All tests passed!');
        process.exit(0);

    } catch (error) {
        console.error(' Test failed:', error.message);
        process.exit(1);
    }
}

// Run the test
testServer();