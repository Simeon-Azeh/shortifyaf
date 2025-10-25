# ShortifyAF 
*A simple URL shortener built for Africa’s digital ecosystem.*

##  Problem Statement
Many small businesses and individuals across Africa share long, confusing URLs (especially for WhatsApp, payment links, or products). These look unprofessional and are hard to remember. **ShortifyAF** helps shorten and manage URLs easily.

##  Target Users
- Small business owners  
- Social media marketers  
- Students and organizations sharing digital links  

##  Core Features
1. Shorten long URLs  
2. Copy shortened URLs easily  
3. View a list of shortened URLs  
4. Basic analytics (optional in future)  
5. Mobile-friendly interface  

##  Technology Stack
- **Frontend:** React + Vite + TypeScript  
- **Backend:** Node.js (Express)  
- **Database:** MongoDB (for later versions)  

##  Setup Instructions
1. Clone the repository  
   ```bash
   git clone https://github.com/Simeon-Azeh/shortifyaf.git
   ```

2. Navigate to the backend directory  
   ```bash
   cd backend
   ```

3. Create a `.env` file in the backend directory and add your environment variables:  
   ```env
   PORT=3000
   MONGODB_URI=mongodb://localhost:27017/shortifyaf
   ```

4. Install dependencies  
   ```bash
   npm install
   ```

5. Ensure MongoDB is running locally (or update MONGODB_URI for your setup)

6. Run the app  
   ```bash
   npm run dev
   ```

## API Documentation
Once the server is running, visit `http://localhost:3000/api-docs` to view the interactive API documentation powered by Swagger UI.

## Team Members
Name	Role
Simeon Azeh	Team Lead / Developer
[Add others if any]	[Role]

License

This project is licensed under the MIT License — see LICENSE
 for details.

