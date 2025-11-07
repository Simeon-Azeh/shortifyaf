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

### Feature 6: Smart Redirect System
When users visit a shortened URL, they see a professional loading screen with a countdown before being redirected to the original destination, creating a seamless and trustworthy experience.

## Technology Stack

- **Frontend**: React 19 + Vite + React Router
- **Backend**: Node.js with Express.js framework
- **Database**: MongoDB with Mongoose ODM
- **API Documentation**: Swagger UI / OpenAPI 3.0
- **Styling**: CSS3 with mobile-first responsive design
- **Icons**: React Icons (Feather Icons)
- **HTTP Client**: Axios
- **Version Control**: Git & GitHub
- **CI/CD**: GitHub Actions
- **Containerization**: Docker
- **Code Quality**: ESLint, automated testing

## CI/CD Pipeline

ShortifyAF uses GitHub Actions for continuous integration and deployment, ensuring code quality and reliability.

### Pipeline Triggers
- **Push to any branch** (except `main`) - Runs full CI suite
- **Pull Request targeting `main`** - Runs full CI suite and blocks merge if failed

### CI Jobs

#### Backend CI
- **Node.js Setup**: Uses Node.js 18 with npm caching for faster builds
- **Dependency Installation**: `npm ci` for clean, reproducible installs
- **Code Linting**: ESLint checks for code quality and consistency
- **Testing**: Automated test suite validates functionality
- **Docker Build**: Ensures containerization works correctly

#### Frontend CI
- **Node.js Setup**: Uses Node.js 18 with npm caching
- **Dependency Installation**: `npm ci` for frontend packages
- **Code Linting**: ESLint ensures React code quality
- **Build Verification**: Confirms production build succeeds

### Quality Gates
The pipeline enforces strict quality standards:
-  **Linting failures** prevent deployment
-  **Test failures** block merges
-  **Build failures** stop the pipeline

### Local Development Commands

#### Backend Scripts
```bash
cd backend

# Install dependencies
npm install

# Start development server
npm run dev

# Run linting
npm run lint

# Run tests
npm test

# Start production server
npm start
```

#### Frontend Scripts
```bash
cd frontend

# Install dependencies
npm install

# Start development server
npm run dev

# Run linting
npm run lint

# Build for production
npm run build

# Preview production build
npm run preview
```

## Docker Deployment

ShortifyAF includes Docker support for easy deployment and scaling.

### Building the Backend Image
```bash
cd backend
docker build -t shortifyaf-backend .
```

### Running with Docker
```bash
# Run the backend container
docker run -p 3000:3000 \
  -e MONGODB_URI=mongodb://your-mongo-uri \
  -e PORT=3000 \
  shortifyaf-backend
```

### Docker Image Features
- **Alpine Linux**: Lightweight base image
- **Non-root user**: Enhanced security
- **Health checks**: Automatic container monitoring
- **Production optimized**: Minimal attack surface

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
│   ├── controllers/          # Request handlers (urlController.js)
│   ├── models/               # Database models (Url.js)
│   ├── routes/               # API routes (urlRoutes.js)
│   ├── tests/                # Test files (test-basic.js)
│   ├── .env                  # Environment variables (not in repo)
│   ├── .eslintrc.js          # ESLint configuration
│   ├── .gitignore           # Backend ignored files
│   ├── Dockerfile           # Docker containerization
│   ├── healthcheck.js       # Container health monitoring
│   ├── index.js             # Main application entry point
│   └── package.json         # Backend dependencies and scripts
├── frontend/
│   ├── src/
│   │   ├── components/      # React components (HomePage, RedirectPage)
│   │   ├── services/        # API service calls (api.js)
│   │   └── ...
│   ├── public/              # Static assets
│   ├── package.json         # Frontend dependencies
│   └── vite.config.js       # Vite configuration
├── .github/
│   ├── workflows/           # GitHub Actions CI/CD
│   │   └── ci.yml          # CI pipeline configuration
│   └── CODEOWNERS           # Code ownership rules
├── .gitignore                # Root gitignore
├── README.md                 # This file
├── LICENSE                   # MIT License
```

## Contributing

We welcome contributions to ShortifyAF! Please follow these guidelines:

### Development Workflow

1. **Fork the repository** and create a feature branch
2. **Run tests locally** before pushing:
   ```bash
   cd backend && npm test && npm run lint
   cd ../frontend && npm run lint && npm run build
   ```
3. **Commit your changes** with clear, descriptive messages
4. **Push to your branch** and create a Pull Request

### CI/CD Requirements

All pull requests must pass the automated CI pipeline, which includes:
-  **Code Linting**: ESLint checks for both frontend and backend
-  **Automated Testing**: Backend functionality tests
-  **Build Verification**: Frontend production build
-  **Docker Build**: Backend containerization verification

The pipeline runs automatically on:
- Pushes to any branch (except `main`)
- Pull requests targeting `main`

### Code Quality Standards

- Follow ESLint rules (no errors allowed)
- Write tests for new features
- Ensure all tests pass
- Keep Docker builds working
- Maintain mobile-responsive design

## Links


## Links

- **GitHub Repository**: [https://github.com/Simeon-Azeh/shortifyaf](https://github.com/Simeon-Azeh/shortifyaf)
- **Project Board**: [View on GitHub Projects](https://github.com/users/Simeon-Azeh/projects/[PROJECT_NUMBER])
- **API Documentation**: http://localhost:3000/api-docs (when running locally)
- **Issues & Bug Reports**: [GitHub Issues](https://github.com/Simeon-Azeh/shortifyaf/issues)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
