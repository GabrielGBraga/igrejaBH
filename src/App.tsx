import { BrowserRouter, Routes, Route } from 'react-router-dom';
import SignIn from './pages/SignIn.tsx';
import SignUp from './pages/SignUp.tsx';
import Home from './pages/Home.tsx';

function App() {
  return (
    <BrowserRouter>
      <Routes>

        <Route path="/" element={<Home />} />
        <Route path="/signin" element={<SignIn />} />
        <Route path="/signup" element={<SignUp />} />

      </Routes>
    </BrowserRouter>
  )
}

export default App
