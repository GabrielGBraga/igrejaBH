import { BrowserRouter, Routes, Route } from 'react-router-dom';
import SignIn from './pages/SignIn.tsx';
import SignUp from './pages/SignUp.tsx';
import Home from './pages/Home.tsx';
import AddHomeGroup from './pages/AddHomeGroup.tsx';
import NotFound from './pages/NotFound.tsx';
import { ProtectedRoute } from './components/ProtectedRoute.tsx';
import { Toaster } from "@/components/ui/sonner";

function App() {
  return (
    <BrowserRouter>
      <Toaster />
      <Routes>

        <Route path="/" element={<ProtectedRoute><Home /></ProtectedRoute>} />
        <Route path="/grupos-caseiros" element={<ProtectedRoute><Home /></ProtectedRoute>} />
        <Route path="/grupos-caseiros/adicionar" element={<ProtectedRoute requireAdmin><AddHomeGroup /></ProtectedRoute>} />
        <Route path="/entrar" element={<SignIn />} />
        <Route path="/cadastro" element={<SignUp />} />
        <Route path="*" element={<NotFound />} />

      </Routes>
    </BrowserRouter>
  )
}

export default App
