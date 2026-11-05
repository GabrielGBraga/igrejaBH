import { lazy, Suspense, useEffect, useState, type ReactNode } from "react"
import { BrowserRouter, Routes, Route, Navigate, Outlet, useLocation } from "react-router-dom"
import supabase from "@/lib/supabase"
import {
  isRestrictedGroupMode,
  enableRestrictedGroupMode,
  disableRestrictedGroupMode,
} from "./lib/restrictedMode"
import { RestrictedGroupLayout } from "./components/layout/RestrictedGroupLayout"
import { Loader2 } from "lucide-react"
import { ProtectedRoute } from "./components/ProtectedRoute"
import { Toaster } from "@/components/ui/sonner"
import { Layout } from "./components/layout/Layout"
import { LandingHeader } from "./components/landing/LandingHeader"
import { LandingFooter } from "./components/landing/LandingFooter"
import { PageLoadingFallback } from "@/components/ui/PageLoadingFallback"

// Lazy loaded pages for optimal route-level code splitting
const Landing = lazy(() => import("./pages/Landing"))
const QuemSomos = lazy(() => import("./pages/QuemSomos"))
const SignIn = lazy(() => import("./pages/SignIn"))
const SignUp = lazy(() => import("./pages/SignUp"))
const Home = lazy(() => import("./pages/Home"))
const AddHomeGroup = lazy(() => import("./pages/AddHomeGroup"))
const Profile = lazy(() => import("./pages/Profile"))
const CreatePost = lazy(() => import("./pages/CreatePost"))
const Ensinos = lazy(() => import("./pages/Ensinos"))
const Events = lazy(() => import("./pages/Events"))
const ManageEvents = lazy(() => import("./pages/ManageEvents"))
const ManageEventDetail = lazy(() => import("./pages/ManageEventDetail"))
const Messages = lazy(() => import("./pages/Messages"))
const NotFound = lazy(() => import("./pages/NotFound"))
const FormBuilder = lazy(() => import("./pages/FormBuilder"))
const FormResponder = lazy(() => import("./pages/FormResponder"))
const RedeRelacionamentos = lazy(() => import("./pages/RedeRelacionamentos"))

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

// Global guard: ensures that users in restricted group mode cannot escape to other pages
function RestrictedModeGuard({ children }: { children: ReactNode }) {
  const location = useLocation()
  const isRestrictedTarget =
    location.pathname === "/meu-grupo" ||
    location.pathname === "/gestao-grupo"

  if (isRestrictedTarget) {
    enableRestrictedGroupMode()
  }

  const restricted = isRestrictedGroupMode()

  useEffect(() => {
    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((event) => {
      if (event === "SIGNED_OUT") {
        disableRestrictedGroupMode()
      }
    })
    return () => subscription.unsubscribe()
  }, [])

  if (restricted) {
    const isAllowedPath =
      location.pathname === "/meu-grupo" ||
      location.pathname === "/gestao-grupo" ||
      location.pathname === "/entrar" ||
      location.pathname === "/login"

    if (!isAllowedPath) {
      return <Navigate to="/meu-grupo" replace />
    }
  }

  return <>{children}</>
}

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
    if (isRestrictedGroupMode()) {
      return <Navigate to="/meu-grupo" replace />
    }
    return <Navigate to="/dashboard" replace />
  }

  if (isRestrictedGroupMode()) {
    return <Navigate to="/meu-grupo" replace />
  }

  return <Landing />
}

// Ensinos route wrapper: provides full member layout for logged-in users,
// and guest header/footer container with open access to written materials for visitors
function EnsinosRoute() {
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

  if (isRestrictedGroupMode()) {
    return <Navigate to="/meu-grupo" replace />
  }

  if (isAuthenticated) {
    return (
      <Layout>
        <Ensinos />
      </Layout>
    )
  }

  return (
    <div className="flex min-h-screen w-full flex-col overflow-x-hidden bg-background text-foreground antialiased selection:bg-primary/20 selection:text-primary">
      <LandingHeader />
      <main className="mx-auto w-full max-w-7xl flex-1 px-4 py-8 sm:px-6 lg:px-8">
        <Ensinos />
      </main>
      <LandingFooter />
    </div>
  )
}

function App() {
  return (
    <BrowserRouter>
      <RestrictedModeGuard>
        <Toaster />
        <Suspense fallback={<PageLoadingFallback />}>
          <Routes>
            <Route path="/" element={<RootRoute />} />
            <Route path="/landing" element={<Landing />} />
            <Route path="/quem-somos" element={<QuemSomos />} />
            <Route path="/quero-saber-mais" element={<Navigate to="/quem-somos" replace />} />
            <Route path="/quero-conhecer" element={<Navigate to="/quem-somos" replace />} />
            <Route path="/conhecer" element={<Navigate to="/quem-somos" replace />} />
            <Route path="/ensinos" element={<EnsinosRoute />} />
            <Route path="/entrar" element={<SignIn />} />
            <Route path="/login" element={<Navigate to="/entrar" replace />} />
            <Route path="/cadastro" element={<SignUp />} />
            <Route path="/formularios/responder/:formId" element={<FormResponder />} />
            <Route path="/formularios/:formId" element={<FormResponder />} />

            {/* Rota do Modo Link Exclusivo do Grupo */}
            <Route
              path="/meu-grupo"
              element={
                <ProtectedRoute>
                  <RestrictedGroupLayout>
                    <RedeRelacionamentos singleGroupMode={true} />
                  </RestrictedGroupLayout>
                </ProtectedRoute>
              }
            />
            <Route path="/gestao-grupo" element={<Navigate to="/meu-grupo" replace />} />

            {/* Protected Routes inside shared Layout */}
            <Route element={<AppLayout />}>
              <Route path="/dashboard" element={<Home />} />
              <Route path="/noticias/nova" element={<CreatePost />} />
              <Route path="/perfil" element={<Profile />} />
              <Route path="/eventos" element={<Events />} />
              <Route path="/mensagens" element={<Messages />} />

              <Route
                path="/grupos-caseiros"
                element={
                  <PermissionGuard requireAdmin>
                    <AddHomeGroup />
                  </PermissionGuard>
                }
              />

              <Route
                path="/gestao"
                element={
                  <PermissionGuard requireManagement>
                    <RedeRelacionamentos />
                  </PermissionGuard>
                }
              />
              <Route path="/gestao/vinculados" element={<Navigate to="/gestao" replace />} />
              <Route path="/gestao/grafo" element={<Navigate to="/gestao" replace />} />

              <Route
                path="/manage-events"
                element={
                  <PermissionGuard requireManagement>
                    <ManageEvents />
                  </PermissionGuard>
                }
              />

              <Route
                path="/manage-events/:eventId"
                element={
                  <PermissionGuard requireManagement>
                    <ManageEventDetail />
                  </PermissionGuard>
                }
              />

              <Route path="/gestao/eventos" element={<Navigate to="/manage-events" replace />} />
              <Route path="/gestao/eventos/:eventId" element={<Navigate to="/manage-events" replace />} />

              <Route
                path="/gestao/formularios"
                element={
                  <PermissionGuard requireCanPost>
                    <FormBuilder />
                  </PermissionGuard>
                }
              />
            </Route>

            <Route path="*" element={<NotFound />} />
          </Routes>
        </Suspense>
      </RestrictedModeGuard>
    </BrowserRouter>
  )
}

export default App
