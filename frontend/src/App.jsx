import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import HomePage from './components/HomePage';
import RedirectPage from './components/RedirectPage';
import './App.css';

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route path="/:shortId" element={<RedirectPage />} />
      </Routes>
    </Router>
  );
}

export default App;

