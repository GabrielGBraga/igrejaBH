import { useEffect, useState } from "react"
import supabase from "@/lib/supabase"

export interface CurrentUserProfile {
  id: string
  full_name: string
  avatar_url?: string | null
  is_dev: boolean
  is_presbyter: boolean
  is_deacon: boolean
  can_post: boolean
  is_church_linked: boolean
}

export function useCurrentUserProfile() {
  const [profile, setProfile] = useState<CurrentUserProfile | null>(null)
  const [isAdmin, setIsAdmin] = useState(false)
  const [isManagement, setIsManagement] = useState(false)
  const [canPost, setCanPost] = useState(false)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    let isMounted = true

    async function fetchUserData() {
      try {
        const {
          data: { session },
        } = await supabase.auth.getSession()

        if (!session?.user) {
          if (isMounted) setLoading(false)
          return
        }

        const { data: profileData } = await supabase
          .from("profiles")
          .select("id, full_name, avatar_url, is_dev, is_presbyter, is_deacon, can_post, is_church_linked")
          .eq("user_id", session.user.id)
          .maybeSingle()

        if (profileData && isMounted) {
          setProfile({
            id: profileData.id,
            full_name: profileData.full_name,
            avatar_url: profileData.avatar_url || null,
            is_dev: !!profileData.is_dev,
            is_presbyter: !!profileData.is_presbyter,
            is_deacon: !!profileData.is_deacon,
            can_post: !!profileData.can_post,
            is_church_linked: profileData.is_church_linked !== false,
          })

          const admin = !!(profileData.is_dev || profileData.is_presbyter)
          const posting = !!(
            profileData.is_dev ||
            profileData.is_presbyter ||
            profileData.can_post
          )

          setIsAdmin(admin)
          setCanPost(posting)

          const { count } = await supabase
            .from("home_groups")
            .select("*", { count: "exact", head: true })
            .or(`leader_1_id.eq.${profileData.id},leader_2_id.eq.${profileData.id}`)

          const management = !!(
            profileData.is_dev ||
            profileData.is_presbyter ||
            profileData.is_deacon ||
            (count || 0) > 0
          )

          setIsManagement(management)
        }
      } catch (err) {
        console.error("Erro ao carregar dados do usuário:", err)
      } finally {
        if (isMounted) setLoading(false)
      }
    }

    fetchUserData()

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((event) => {
      if (event === "SIGNED_IN" || event === "USER_UPDATED") {
        fetchUserData()
      } else if (event === "SIGNED_OUT") {
        if (isMounted) {
          setProfile(null)
          setIsAdmin(false)
          setIsManagement(false)
          setCanPost(false)
        }
      }
    })

    return () => {
      isMounted = false
      subscription.unsubscribe()
    }
  }, [])

  return {
    profile,
    isAdmin,
    isManagement,
    canPost,
    loading,
  }
}
