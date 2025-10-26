import { useState } from 'react';
import { shortenUrl } from '../services/api';
import './HomePage.css';

const HomePage = () => {
    const [longUrl, setLongUrl] = useState('');
    const [shortUrl, setShortUrl] = useState('');
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');
    const [copied, setCopied] = useState(false);

    const validateUrl = (url) => {
        try {
            new URL(url);
            return true;
        } catch (err) {
            return false;
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();

        // Reset states
        setError('');
        setShortUrl('');
        setCopied(false);

        // Validate URL
        if (!longUrl.trim()) {
            setError('Please enter a URL');
            return;
        }

        if (!validateUrl(longUrl)) {
            setError('Please enter a valid URL (e.g., https://example.com)');
            return;
        }

        setLoading(true);

        try {
            const response = await shortenUrl(longUrl);
            setShortUrl(response.shortUrl);
            setLongUrl(''); // Clear input after success
        } catch (err) {
            setError(err.message || 'Failed to shorten URL. Please try again.');
        } finally {
            setLoading(false);
        }
    };

    const handleCopy = async () => {
        try {
            await navigator.clipboard.writeText(shortUrl);
            setCopied(true);
            setTimeout(() => setCopied(false), 2000);
        } catch (err) {
            setError('Failed to copy to clipboard');
        }
    };

    return (
        <div className="home-page">
            <div className="container">
                <header className="header">
                    <h1 className="title">ShortifyAF</h1>
                    <p className="subtitle">A simple URL shortener for Africa's digital ecosystem</p>
                </header>

                <form onSubmit={handleSubmit} className="url-form">
                    <div className="input-group">
                        <input
                            type="text"
                            value={longUrl}
                            onChange={(e) => setLongUrl(e.target.value)}
                            placeholder="Enter your long URL here (e.g., https://example.com/very/long/url)"
                            className="url-input"
                            disabled={loading}
                        />
                        <button
                            type="submit"
                            className="shorten-btn"
                            disabled={loading}
                        >
                            {loading ? (
                                <span className="loading-spinner"></span>
                            ) : (
                                'Shorten'
                            )}
                        </button>
                    </div>

                    {error && (
                        <div className="error-message">
                            <svg className="error-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                            {error}
                        </div>
                    )}
                </form>

                {shortUrl && (
                    <div className="result-section">
                        <div className="result-card">
                            <h3 className="result-title">Your shortened URL is ready! 🎉</h3>
                            <div className="url-display">
                                <input
                                    type="text"
                                    value={shortUrl}
                                    readOnly
                                    className="short-url-input"
                                />
                                <button onClick={handleCopy} className="copy-btn">
                                    {copied ? (
                                        <>
                                            <svg className="icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                                            </svg>
                                            Copied!
                                        </>
                                    ) : (
                                        <>
                                            <svg className="icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
                                            </svg>
                                            Copy
                                        </>
                                    )}
                                </button>
                            </div>
                        </div>
                    </div>
                )}

                <div className="features">
                    <div className="feature">
                        <div className="feature-icon">⚡</div>
                        <h3>Fast & Simple</h3>
                        <p>Shorten URLs in seconds</p>
                    </div>
                    <div className="feature">
                        <div className="feature-icon">🔒</div>
                        <h3>Secure</h3>
                        <p>Your links are safe with us</p>
                    </div>
                    <div className="feature">
                        <div className="feature-icon">📱</div>
                        <h3>Mobile-Friendly</h3>
                        <p>Works on all devices</p>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default HomePage;
