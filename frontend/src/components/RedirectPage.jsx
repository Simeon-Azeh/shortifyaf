import { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { getOriginalUrl } from '../services/api';
import { FiLink, FiAlertCircle, FiHome } from 'react-icons/fi';
import { BiLoaderAlt } from 'react-icons/bi';
import './RedirectPage.css';

const RedirectPage = () => {
    const { shortId } = useParams();
    const navigate = useNavigate();
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const [countdown, setCountdown] = useState(3);

    useEffect(() => {
        const fetchAndRedirect = async () => {
            if (!shortId) {
                setError('Invalid short URL');
                setLoading(false);
                return;
            }

            try {
                setLoading(true);

                // Call backend to get original URL
                const response = await getOriginalUrl(shortId);

                if (response.originalUrl) {
                    // Start countdown before redirect
                    let count = 3;
                    setCountdown(count);

                    const countdownInterval = setInterval(() => {
                        count--;
                        setCountdown(count);

                        if (count === 0) {
                            clearInterval(countdownInterval);
                            // Redirect to original URL
                            window.location.href = response.originalUrl;
                        }
                    }, 1000);

                } else {
                    setError('URL not found');
                    setLoading(false);
                }
            } catch (err) {
                setError(err.message || 'Short URL not found');
                setLoading(false);
            }
        };

        fetchAndRedirect();
    }, [shortId]);

    const handleGoHome = () => {
        navigate('/');
    };

    if (loading && !error) {
        return (
            <div className="redirect-page">
                <div className="redirect-container">
                    <div className="redirect-card loading-card">
                        <BiLoaderAlt className="spinner-icon" />
                        <h2>Fetching URL...</h2>
                        <p>Please wait while we retrieve your destination</p>
                        <div className="loading-bar">
                            <div className="loading-progress"></div>
                        </div>
                    </div>
                </div>
            </div>
        );
    }

    if (countdown > 0 && !error) {
        return (
            <div className="redirect-page">
                <div className="redirect-container">
                    <div className="redirect-card success-card">
                        <div className="success-icon">
                            <FiLink />
                        </div>
                        <h2>URL Found! 🎉</h2>
                        <p>Redirecting you in...</p>
                        <div className="countdown">{countdown}</div>
                        <div className="redirect-info">
                            <p className="info-text">You'll be redirected automatically</p>
                        </div>
                    </div>
                </div>
            </div>
        );
    }

    if (error) {
        return (
            <div className="redirect-page">
                <div className="redirect-container">
                    <div className="redirect-card error-card">
                        <div className="error-icon">
                            <FiAlertCircle />
                        </div>
                        <h2>URL Not Found</h2>
                        <p className="error-message">{error}</p>
                        <div className="error-details">
                            <p>The short URL you're looking for doesn't exist or may have expired.</p>
                        </div>
                        <button onClick={handleGoHome} className="home-btn">
                            <FiHome />
                            Go to Home
                        </button>
                        <div className="help-text">
                            <p>Need help? Make sure you've entered the correct URL.</p>
                        </div>
                    </div>
                </div>
            </div>
        );
    }

    return null;
};

export default RedirectPage;
