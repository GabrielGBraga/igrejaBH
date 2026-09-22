import { BrowserRouter, Routes, Route, Navigate, Outlet } from "react-router-dom";
import { useEffect, useState } from "react";
import supabase from "@/lib/supabase";
import { Loader2 } from "lucide-react";
import Landing from "./pages/Landing.tsx";
import SignIn from "./pages/SignIn.tsx";
import SignUp from "./pages/SignUp.tsx";
import Home from "./pages/Home.tsx";
import AddHomeGroup from "./pages/AddHomeGroup.tsx";
import Profile from "./pages/Profile.tsx";
import CreatePost from "./pages/CreatePost.tsx";
import Ensinos from "./pages/Ensinos.tsx";
import Events from "./pages/Events.tsx";
import ManageEvents from "./pages/ManageEvents.tsx";
import ManageEventDetail from "./pages/ManageEventDetail.tsx";
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

// Helper component to provide Layout context to protected routes
const AppLayout = () => (
  <ProtectedRoute>
    <Layout>
      <Outlet />
    </Layout>
  </ProtectedRoute>
)

// Helper component for specific permissions within the layout
const PermissionGuard = ({
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
    {children}
  </ProtectedRoute>
)

// Root route dispatcher: landing page for unlogged users, dashboard for authenticated users
function RootRoute() {
  const [isAuthenticated, setIsAuthenticated] = useState<boolean | null>(null)

  useEffect(() => {
    let active = true

    supabase.auth.getSession().then(({ data: { session } }) => {
      if (active) {
        setIsAuthenticated(!!session?.user)
      }
    })

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      if (active) {
        setIsAuthenticated(!!session?.user)
      }
    })

    return () => {
      active = false
      subscription.unsubscribe()
    }
  }, [])

  if (isAuthenticated === null) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-background">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
      </div>
    )
  }

  if (isAuthenticated) {
    return <Navigate to="/dashboard" replace />
  }

  return <Landing />
}

function App() {
  return (
    <BrowserRouter>
      <Toaster />
      <Routes>
        <Route path="/" element={<RootRoute />} />
        <Route path="/landing" element={<Landing />} />
        <Route path="/entrar" element={<SignIn />} />
        <Route path="/cadastro" element={<SignUp />} />
        <Route path="/formularios/responder/:formId" element={<FormResponder />} />

        {/* Protected Routes inside shared Layout */}
        <Route element={<AppLayout />}>
          <Route path="/dashboard" element={<Home />} />
          <Route path="/noticias/nova" element={<CreatePost />} />
          <Route path="/ensinos" element={<Ensinos />} />
          <Route path="/perfil" element={<Profile />} />
          <Route path="/eventos" element={<Events />} />
          <Route path="/mensagens" element={<Messages />} />
          <Route path="/ajustes" element={<Settings />} />

          <Route path="/grupos-caseiros" element={
            <PermissionGuard requireAdmin><AddHomeGroup /></PermissionGuard>
          } />
          
          <Route path="/gestao/vinculados" element={<Navigate to="/gestao/grafo" replace />} />
          
          <Route path="/gestao/grafo" element={
            <PermissionGuard requireManagement><RedeRelacionamentos /></PermissionGuard>
          } />
          
          <Route path="/manage-events" element={
            <PermissionGuard requireManagement><ManageEvents /></PermissionGuard>
          } />
          
          <Route path="/manage-events/:eventId" element={
            <PermissionGuard requireManagement><ManageEventDetail /></PermissionGuard>
          } />

          <Route path="/gestao/eventos" element={<Navigate to="/manage-events" replace />} />
          <Route path="/gestao/eventos/:eventId" element={<Navigate to="/manage-events" replace />} />
          
          <Route path="/gestao/formularios" element={
            <PermissionGuard requireCanPost><FormBuilder /></PermissionGuard>
          } />
        </Route>

        <Route path="*" element={<NotFound />} />
      </Routes>
    </BrowserRouter>
  )
}

export default App;
