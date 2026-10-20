import { useEffect, useState, useCallback, useMemo } from "react"
import supabase from "@/lib/supabase"
import type { Database } from "@/lib/database.types"
import { isAfter, isSameDay, parseISO, startOfDay } from "date-fns"

export type Post = Database["public"]["Tables"]["posts"]["Row"]
export type PostCategory = Database["public"]["Enums"]["post_category"]

export type PostWithRelations = Post & {
  author?: {
    id: string
    full_name: string
    avatar_url: string | null
  } | null
  media_resources?: Database["public"]["Tables"]["media_resources"]["Row"] | null
  forms?: Pick<
    Database["public"]["Tables"]["forms"]["Row"],
    "id" | "name" | "description" | "is_public"
  > | null
  retreats?: Pick<
    Database["public"]["Tables"]["retreats"]["Row"],
    "id" | "title" | "start_date" | "end_date" | "location_text" | "status" | "price"
  > | null
}

export interface UseNewsFeedOptions {
  publicOnly?: boolean
  category?: PostCategory | "todos"
  limit?: number
}

export function useNewsFeed(options: UseNewsFeedOptions = {}) {
  const { publicOnly = false, category = "todos", limit } = options
  const [posts, setPosts] = useState<PostWithRelations[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  const fetchPosts = useCallback(async () => {
    setLoading(true)
    setError(null)

    try {
      let query = supabase
        .from("posts")
        .select(`
          *,
          author:profiles!posts_author_id_fkey(id, full_name, avatar_url),
          media_resources(*),
          forms(id, name, description, is_public),
          retreats(id, title, start_date, end_date, location_text, status, price)
        `)
        .eq("is_published", true)

      if (publicOnly) {
        query = query.eq("is_public", true)
      }

      if (category && category !== "todos") {
        query = query.eq("category", category)
      }

      query = query.order("created_at", { ascending: false })

      if (limit) {
        query = query.limit(limit)
      }

      const { data, error: queryError } = await query

      if (queryError) throw queryError

      setPosts((data as unknown as PostWithRelations[]) || [])
    } catch (err) {
      console.error("Erro ao buscar feed de notícias:", err)
      setError(err as Error)
    } finally {
      setLoading(false)
    }
  }, [publicOnly, category, limit])

  useEffect(() => {
    fetchPosts()
  }, [fetchPosts])

  // Itens de feed ordenados por publicação recente
  const feedItems = posts

  // Encontros casuais futuros para alimentar o calendário
  const casualMeetings = useMemo(() => {
    const today = startOfDay(new Date())
    return posts
      .filter((p) => {
        if (!p.event_start_date) return false
        try {
          const start = parseISO(p.event_start_date)
          return isAfter(start, today) || isSameDay(start, today)
        } catch {
          return false
        }
      })
      .sort((a, b) => {
        if (!a.event_start_date || !b.event_start_date) return 0
        return new Date(a.event_start_date).getTime() - new Date(b.event_start_date).getTime()
      })
  }, [posts])

  return {
    posts,
    feedItems,
    casualMeetings,
    loading,
    error,
    refetch: fetchPosts,
  }
}
