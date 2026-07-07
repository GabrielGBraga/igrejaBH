import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import SignIn from "./pages/SignIn.tsx";
import SignUp from "./pages/SignUp.tsx";
import Home from "./pages/Home.tsx";
import AddHomeGroup from "./pages/AddHomeGroup.tsx";
import Profile from "./pages/Profile.tsx";
import CreatePost from "./pages/CreatePost.tsx";
import Ensinos from "./pages/Ensinos.tsx";
import Events from "./pages/Events.tsx";
import ManageEvents from "./pages/ManageEvents.tsx";
import Messages from "./pages/Messages.tsx";
import Settings from "./pages/Settings.tsx";
import NotFound from "./pages/NotFound.tsx";
import FormBuilder from "./pages/FormBuilder.tsx";
import FormResponder from "./pages/FormResponder.tsx";
import RedeRelacionamentos from "./pages/RedeRelacionamentos.tsx";
import { ProtectedRoute } from "./components/ProtectedRoute.tsx";
import { Toaster } from "@/components/ui/sonner";
import { Layout } from "./components/layout/Layout.tsx";
import type { ReactNode } from "react";

// Helper component to wrap protected routes with Layout
const AuthenticatedLayout = ({
  children,
  requireAdmin,
  requireManagement,
  requireCanPost,
}: {
  children: ReactNode
  requireAdmin?: boolean
  requireManagement?: boolean
  requireCanPost?: boolean
}) => (
  <ProtectedRoute
    requireAdmin={requireAdmin}
    requireManagement={requireManagement}
    requireCanPost={requireCanPost}
  >
    <Layout>{children}</Layout>
  </ProtectedRoute>
)

function App() {
  return (
    <BrowserRouter>
      <Toaster />
      <Routes>
        <Route path="/" element={<AuthenticatedLayout><Home /></AuthenticatedLayout>} />
        <Route path="/grupos-caseiros" element={<AuthenticatedLayout requireAdmin><AddHomeGroup /></AuthenticatedLayout>} />
        <Route path="/gestao/vinculados" element={<Navigate to="/gestao/grafo" replace />} />
        <Route path="/gestao/grafo" element={<AuthenticatedLayout requireManagement><RedeRelacionamentos /></AuthenticatedLayout>} />
        <Route path="/gestao/formularios" element={<AuthenticatedLayout requireCanPost><FormBuilder /></AuthenticatedLayout>} />
        <Route path="/formularios/responder/:formId" element={<FormResponder />} />
        <Route path="/noticias/nova" element={<AuthenticatedLayout><CreatePost /></AuthenticatedLayout>} />
        <Route path="/ensinos" element={<AuthenticatedLayout><Ensinos /></AuthenticatedLayout>} />
        <Route path="/perfil" element={<AuthenticatedLayout><Profile /></AuthenticatedLayout>} />
        <Route path="/eventos" element={<AuthenticatedLayout><Events /></AuthenticatedLayout>} />
        <Route path="/gestao/eventos" element={<AuthenticatedLayout requireManagement><ManageEvents /></AuthenticatedLayout>} />
        <Route path="/mensagens" element={<AuthenticatedLayout><Messages /></AuthenticatedLayout>} />
        <Route path="/ajustes" element={<AuthenticatedLayout><Settings /></AuthenticatedLayout>} />
        <Route path="/entrar" element={<SignIn />} />
        <Route path="/cadastro" element={<SignUp />} />
        <Route path="*" element={<NotFound />} />
      </Routes>
    </BrowserRouter>
  )
}

export default App;
