import { useState } from 'react';
import { shortenUrl } from '../services/api';
import { FiLink, FiCopy, FiCheck, FiAlertCircle, FiZap, FiLock, FiSmartphone } from 'react-icons/fi';
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
        } catch {
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
        } catch {
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
                            <FiAlertCircle className="error-icon" />
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
                                            <FiCheck className="icon" />
                                            Copied!
                                        </>
                                    ) : (
                                        <>
                                            <FiCopy className="icon" />
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
                        <div className="feature-icon">
                            <FiZap />
                        </div>
                        <h3>Fast & Simple</h3>
                        <p>Shorten URLs in seconds</p>
                    </div>
                    <div className="feature">
                        <div className="feature-icon">
                            <FiLock />
                        </div>
                        <h3>Secure</h3>
                        <p>Your links are safe with us</p>
                    </div>
                    <div className="feature">
                        <div className="feature-icon">
                            <FiSmartphone />
                        </div>
                        <h3>Mobile-Friendly</h3>
                        <p>Works on all devices</p>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default HomePage;
