import { useEffect, useSyncExternalStore } from "react"
import supabase from "@/lib/supabase"
import type { User } from "@supabase/supabase-js"

export interface CurrentUserProfile {
  id: string
  user_id: string
  full_name: string
  avatar_url?: string | null
  is_dev: boolean
  is_presbyter: boolean
  is_deacon: boolean
  can_post: boolean
  is_church_linked: boolean
  is_leader: boolean
}

export interface ProfileCacheState {
  user: User | null
  profile: CurrentUserProfile | null
  isAdmin: boolean
  isManagement: boolean
  canPost: boolean
  loading: boolean
  timestamp: number
}

const CACHE_KEY = "igrejaBH_profile_cache_v1"

// 1. Initial State from localStorage for instant (0ms) render on frame 0
function getInitialCache(): ProfileCacheState {
  try {
    if (typeof window !== "undefined") {
      const raw = localStorage.getItem(CACHE_KEY)
      if (raw) {
        const parsed = JSON.parse(raw)
        if (parsed && typeof parsed === "object" && parsed.profile) {
          return {
            user: parsed.user || null,
            profile: parsed.profile,
            isAdmin: !!parsed.isAdmin,
            isManagement: !!parsed.isManagement,
            canPost: !!parsed.canPost,
            loading: false, // Instant synchronous display
            timestamp: parsed.timestamp || Date.now(),
          }
        }
      }
    }
  } catch (e) {
    console.warn("Falha ao recuperar cache de perfil:", e)
  }

  return {
    user: null,
    profile: null,
    isAdmin: false,
    isManagement: false,
    canPost: false,
    loading: true,
    timestamp: 0,
  }
}

let currentState: ProfileCacheState = getInitialCache()
const listeners = new Set<() => void>()

function emitChange() {
  for (const listener of listeners) {
    listener()
  }
}

function updateState(partial: Partial<ProfileCacheState>) {
  currentState = { ...currentState, ...partial }
  try {
    if (typeof window !== "undefined") {
      if (currentState.user && currentState.profile) {
        localStorage.setItem(
          CACHE_KEY,
          JSON.stringify({
            user: currentState.user,
            profile: currentState.profile,
            isAdmin: currentState.isAdmin,
            isManagement: currentState.isManagement,
            canPost: currentState.canPost,
            timestamp: Date.now(),
          })
        )
      } else if (!currentState.loading && !currentState.user) {
        localStorage.removeItem(CACHE_KEY)
      }
    }
  } catch (e) {
    console.warn("Falha ao salvar cache de perfil:", e)
  }
  emitChange()
}

// Global in-flight deduplication promise
let activeFetchPromise: Promise<ProfileCacheState | null> | null = null

export async function fetchUserProfile(forceRefresh = false): Promise<ProfileCacheState | null> {
  if (activeFetchPromise && !forceRefresh) {
    return activeFetchPromise
  }

  activeFetchPromise = (async () => {
    try {
      const {
        data: { session },
      } = await supabase.auth.getSession()

      if (!session?.user) {
        updateState({
          user: null,
          profile: null,
          isAdmin: false,
          isManagement: false,
          canPost: false,
          loading: false,
          timestamp: Date.now(),
        })
        return currentState
      }

      const userId = session.user.id

      // 1. Fetch user profile
      const { data: profileData, error: profileErr } = await supabase
        .from("profiles")
        .select(
          "id, user_id, full_name, avatar_url, is_dev, is_presbyter, is_deacon, can_post, is_church_linked"
        )
        .eq("user_id", userId)
        .maybeSingle()

      if (profileErr) {
        console.error("Erro ao buscar perfil:", profileErr)
      }

      if (!profileData) {
        updateState({
          user: session.user,
          profile: null,
          isAdmin: false,
          isManagement: false,
          canPost: false,
          loading: false,
          timestamp: Date.now(),
        })
        return currentState
      }

      // 2. Fetch leadership status
      const { count } = await supabase
        .from("home_groups")
        .select("*", { count: "exact", head: true })
        .or(`leader_1_id.eq.${profileData.id},leader_2_id.eq.${profileData.id}`)

      const isLeader = (count || 0) > 0
      const admin = !!(profileData.is_dev || profileData.is_presbyter)
      const posting = !!(
        profileData.is_dev ||
        profileData.is_presbyter ||
        profileData.can_post
      )
      const management = !!(
        profileData.is_dev ||
        profileData.is_presbyter ||
        profileData.is_deacon ||
        isLeader
      )

      const fullProfile: CurrentUserProfile = {
        id: profileData.id,
        user_id: profileData.user_id || session.user.id,
        full_name: profileData.full_name,
        avatar_url: profileData.avatar_url || null,
        is_dev: !!profileData.is_dev,
        is_presbyter: !!profileData.is_presbyter,
        is_deacon: !!profileData.is_deacon,
        can_post: !!profileData.can_post,
        is_church_linked: profileData.is_church_linked !== false,
        is_leader: isLeader,
      }

      updateState({
        user: session.user,
        profile: fullProfile,
        isAdmin: admin,
        isManagement: management,
        canPost: posting,
        loading: false,
        timestamp: Date.now(),
      })

      return currentState
    } catch (err) {
      console.error("Erro inesperado ao carregar dados do usuário:", err)
      updateState({ loading: false })
      return currentState
    } finally {
      activeFetchPromise = null
    }
  })()

  return activeFetchPromise
}

// Invalidate & refresh cache immediately
export function invalidateCurrentUserProfileCache() {
  return fetchUserProfile(true)
}

// Global Auth event listener for automatic revalidation and cleanup
if (typeof window !== "undefined") {
  supabase.auth.onAuthStateChange((event) => {
    if (event === "SIGNED_IN" || event === "USER_UPDATED") {
      fetchUserProfile(true)
    } else if (event === "SIGNED_OUT") {
      updateState({
        user: null,
        profile: null,
        isAdmin: false,
        isManagement: false,
        canPost: false,
        loading: false,
        timestamp: Date.now(),
      })
    }
  })
}

export function useCurrentUserProfile() {
  const state = useSyncExternalStore(
    (callback) => {
      listeners.add(callback)
      return () => {
        listeners.delete(callback)
      }
    },
    () => currentState,
    () => currentState
  )

  useEffect(() => {
    // Stale-While-Revalidate: revalidate if not loaded, if profile missing, or if cache is older than 3 minutes
    const isStale = Date.now() - state.timestamp > 3 * 60 * 1000
    if (state.loading || isStale || !state.profile) {
      fetchUserProfile()
    }
  }, [state.loading, state.timestamp, state.profile])

  return {
    ...state,
    refresh: () => fetchUserProfile(true),
  }
}
