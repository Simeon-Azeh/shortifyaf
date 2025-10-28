import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:3001';

const api = axios.create({
    baseURL: API_BASE_URL,
    headers: {
        'Content-Type': 'application/json',
    },
});

export const shortenUrl = async (url) => {
    try {
        const response = await api.post('/shorten', { url });
        return response.data;
    } catch (error) {
        if (error.response) {
            // Server responded with error
            throw new Error(error.response.data.error || 'Failed to shorten URL');
        } else if (error.request) {
            // Request made but no response
            throw new Error('No response from server. Please check if the backend is running.');
        } else {
            // Error in setting up request
            throw new Error('Failed to make request');
        }
    }
};

export const getHistory = async () => {
    try {
        const response = await api.get('/history');
        return response.data;
    } catch (error) {
        if (error.response) {
            throw new Error(error.response.data.error || 'Failed to fetch history');
        } else if (error.request) {
            throw new Error('No response from server. Please check if the backend is running.');
        } else {
            throw new Error('Failed to make request');
        }
    }
};

export const getOriginalUrl = async (shortId) => {
    try {
        const response = await api.get(`/${shortId}`, {
            maxRedirects: 0,
            validateStatus: function (status) {
                return status >= 200 && status < 400;
            }
        });

        // If we get a redirect response, extract the location
        if (response.status === 302 || response.status === 301) {
            return { originalUrl: response.headers.location };
        }

        return response.data;
    } catch (error) {
        if (error.response) {
            if (error.response.status === 404) {
                throw new Error('Short URL not found');
            }
            // Handle redirect manually
            if (error.response.status === 302 || error.response.status === 301) {
                return { originalUrl: error.response.headers.location };
            }
            throw new Error(error.response.data.error || 'Failed to fetch URL');
        } else if (error.request) {
            throw new Error('No response from server. Please check if the backend is running.');
        } else {
            throw new Error('Failed to make request');
        }
    }
};

export default api;
