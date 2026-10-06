import { createClient } from "@supabase/supabase-js"
import type { Database } from "./database.types"

const supabaseUrl =
  import.meta.env.VITE_SUPABASE_URL || "https://eumywbtukexzmjgpxmsp.supabase.co"
const supabaseKey =
  import.meta.env.VITE_SUPABASE_PUBLISHABLE_DEFAULT_KEY ||
  import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY ||
  "sb_publishable_9KbHig4vXkXWIqzJzpNmZQ_5qn5nRkz"

const supabase = createClient<Database>(supabaseUrl, supabaseKey)

export default supabase