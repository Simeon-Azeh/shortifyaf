# ShortifyAF
**A simple URL shortener built for Africa's digital ecosystem**

## African Context

In Africa's rapidly growing digital economy, small businesses, entrepreneurs, and social media marketers face a common challenge: sharing long, complex URLs that look unprofessional and are difficult to remember. Whether it's WhatsApp business links, mobile money payment URLs, or product pages, these lengthy links create friction in digital communication and commerce.

ShortifyAF addresses this problem by providing a free, easy-to-use URL shortening service tailored for Africa's mobile-first internet users. With many Africans accessing the internet primarily through mobile devices with limited data and screen space, short, clean URLs are not just convenient—they're essential for effective digital communication and business growth.

This tool empowers small business owners, content creators, and organizations to present professional, memorable links that build trust and improve user experience across WhatsApp, Facebook, Instagram, and other platforms popular in African markets.

## Team Members

- **Simeon Azeh** - Full Stack Developer & Team Lead 
- **Yvette Kwizera** - Frontend Developer & UI/UX 
- **Yusuf Molumo** - DevOps Engineer & Documentation Lead

## Project Overview

ShortifyAF is a modern URL shortening service designed specifically for African entrepreneurs, marketers, and digital users. The application allows users to transform lengthy, unwieldy URLs into short, memorable links that are perfect for sharing across social media, messaging apps, and digital marketing campaigns.

Built with a mobile-first approach, ShortifyAF understands the unique challenges of Africa's digital landscape—limited data plans, mobile-dominant internet usage, and the need for simple, accessible tools. Our platform provides instant URL shortening without requiring user registration, making it accessible to anyone with an internet connection.

As we grow, ShortifyAF will incorporate analytics features to help businesses track link performance, understand their audience, and optimize their digital marketing efforts—all while remaining free and accessible to users across the African continent.

## Target Users

- **Small Business Owners**: Entrepreneurs selling products via WhatsApp, Facebook, or Instagram who need professional-looking links
- **Social Media Marketers**: Digital marketers managing campaigns across multiple platforms who need trackable, branded links
- **Students & Organizations**: Educational institutions and NGOs sharing resources, forms, and announcements
- **Content Creators**: Bloggers, YouTubers, and influencers sharing content across various channels
- **Event Organizers**: Anyone sharing registration links, location details, or event information

## Core Features

### Feature 1: Instant URL Shortening
Users can paste any long URL and instantly receive a shortened version. No registration required, no waiting—just immediate results optimized for mobile sharing.

### Feature 2: Easy Copy-to-Clipboard
One-click copying of shortened URLs makes sharing effortless. Designed for mobile users who need quick, friction-free URL sharing on messaging apps.

### Feature 3: URL Management Dashboard
View all your shortened URLs in one place. Keep track of links you've created and quickly access them when needed.

### Feature 4: API Documentation (Swagger)
Developers can integrate ShortifyAF into their own applications using our well-documented REST API, enabling automation and custom implementations.

### Feature 5: Mobile-Responsive Interface
Fully optimized for mobile devices, ensuring African users accessing via smartphones have the best possible experience with fast load times and intuitive navigation.

## Technology Stack

- **Frontend**: React 18 + Vite + TypeScript
- **Backend**: Node.js with Express.js framework
- **Database**: MongoDB (for production deployments)
- **API Documentation**: Swagger UI / OpenAPI
- **Styling**: CSS3 with mobile-first responsive design
- **Version Control**: Git & GitHub
- **Future DevOps**: Docker, CI/CD pipelines, cloud deployment

## Getting Started

### Prerequisites

Before running ShortifyAF, ensure you have the following installed:

- **Node.js** (v16.0 or higher) - [Download here](https://nodejs.org/)
- **npm** (comes with Node.js) or **yarn**
- **MongoDB** (v4.4 or higher) - [Download here](https://www.mongodb.com/try/download/community)
- **Git** - [Download here](https://git-scm.com/downloads)

### Installation

Follow these steps to get ShortifyAF running on your local machine:

#### 1. Clone the Repository

```bash
git clone https://github.com/Simeon-Azeh/shortifyaf.git
cd shortifyaf
```

#### 2. Set Up the Backend

```bash
# Navigate to backend directory
cd backend

# Create environment variables file
# Create a file named .env in the backend directory
touch .env
```

Add the following to your `.env` file:

```env
PORT=3000
MONGODB_URI=mongodb://localhost:27017/shortifyaf
NODE_ENV=development
```

```bash
# Install backend dependencies
npm install

# Start the backend server
npm run dev
```

The backend server will start on `http://localhost:3000`

#### 3. Set Up the Frontend (if separate)

```bash
# Open a new terminal window
# Navigate to frontend directory (if exists)
cd frontend

# Install frontend dependencies
npm install

# Start the development server
npm run dev
```

#### 4. Verify MongoDB is Running

Ensure MongoDB is running on your system:

```bash
# For macOS (if installed via Homebrew)
brew services start mongodb-community

# For Linux
sudo systemctl start mongod

# For Windows
# MongoDB should start automatically as a service
```

### Usage

Once both servers are running:

1. **Access the Application**: Open your browser and go to `http://localhost:5173` (or the port shown in your terminal)

2. **Shorten a URL**:
   - Paste your long URL into the input field
   - Click "Shorten" button
   - Your shortened URL appears instantly

3. **Copy the Short URL**:
   - Click the "Copy" button next to your shortened URL
   - Paste it anywhere—WhatsApp, Twitter, Facebook, email

4. **View Your Links**:
   - All shortened URLs appear in the dashboard
   - Track which links you've created

5. **API Access**:
   - Visit `http://localhost:3000/api-docs` for interactive API documentation
   - Use the API endpoints to integrate with your own applications


## Project Structure

```
shortifyaf/
├── backend/
│   ├── src/
│   │   ├── controllers/      # Request handlers
│   │   ├── models/            # Database models
│   │   ├── routes/            # API routes
│   │   ├── middleware/        # Custom middleware
│   │   └── utils/             # Helper functions
│   ├── .env                   # Environment variables (not in repo)
│   ├── .gitignore            # Backend ignored files
│   ├── package.json          # Backend dependencies
│   └── server.js             # Entry point
├── frontend/
│   ├── src/
│   │   ├── components/       # React components
│   │   ├── pages/            # Page components
│   │   ├── services/         # API service calls
│   │   └── styles/           # CSS files
│   ├── public/               # Static assets
│   ├── package.json          # Frontend dependencies
│   └── vite.config.ts        # Vite configuration
├── .github/
│   ├── CODEOWNERS            # Code ownership rules
│   └── workflows/            # CI/CD pipelines (future)
├── .gitignore                # Root gitignore
├── README.md                 # This file
├── LICENSE                   # MIT License
└── docker-compose.yml        # Docker setup (future)
```

## Links

- **GitHub Repository**: [https://github.com/Simeon-Azeh/shortifyaf](https://github.com/Simeon-Azeh/shortifyaf)
- **Project Board**: [View on GitHub Projects](https://github.com/users/Simeon-Azeh/projects/[PROJECT_NUMBER])
- **API Documentation**: http://localhost:3000/api-docs (when running locally)
- **Issues & Bug Reports**: [GitHub Issues](https://github.com/Simeon-Azeh/shortifyaf/issues)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
