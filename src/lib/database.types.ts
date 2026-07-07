export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.4"
  }
  public: {
    Tables: {
      fellowships: {
        Row: {
          created_at: string | null
          member_a_id: string
          member_b_id: string
        }
        Insert: {
          created_at?: string | null
          member_a_id: string
          member_b_id: string
        }
        Update: {
          created_at?: string | null
          member_a_id?: string
          member_b_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "fellowships_member_a_id_fkey"
            columns: ["member_a_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fellowships_member_b_id_fkey"
            columns: ["member_b_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      form_submissions: {
        Row: {
          data: Json
          form_id: string
          id: string
          submitted_at: string
          user_id: string | null
        }
        Insert: {
          data: Json
          form_id: string
          id: string
          submitted_at?: string
          user_id?: string | null
        }
        Update: {
          data?: Json
          form_id?: string
          id?: string
          submitted_at?: string
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "form_submissions_form_id_fkey"
            columns: ["form_id"]
            isOneToOne: false
            referencedRelation: "forms"
            referencedColumns: ["id"]
          },
        ]
      }
      forms: {
        Row: {
          created_at: string
          created_by: string | null
          description: string | null
          fields: Json
          id: string
          is_active: boolean | null
          is_public: boolean
          name: string
        }
        Insert: {
          created_at?: string
          created_by?: string | null
          description?: string | null
          fields: Json
          id: string
          is_active?: boolean | null
          is_public?: boolean
          name: string
        }
        Update: {
          created_at?: string
          created_by?: string | null
          description?: string | null
          fields?: Json
          id?: string
          is_active?: boolean | null
          is_public?: boolean
          name?: string
        }
        Relationships: []
      }
      home_groups: {
        Row: {
          created_at: string | null
          id: string
          lat: number | null
          leader_1_id: string | null
          leader_2_id: string | null
          lng: number | null
          location_text: string | null
          meeting_day: number | null
          sector_id: string | null
          start_time: string | null
        }
        Insert: {
          created_at?: string | null
          id?: string
          lat?: number | null
          leader_1_id?: string | null
          leader_2_id?: string | null
          lng?: number | null
          location_text?: string | null
          meeting_day?: number | null
          sector_id?: string | null
          start_time?: string | null
        }
        Update: {
          created_at?: string | null
          id?: string
          lat?: number | null
          leader_1_id?: string | null
          leader_2_id?: string | null
          lng?: number | null
          location_text?: string | null
          meeting_day?: number | null
          sector_id?: string | null
          start_time?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "home_groups_leader_1_id_fkey"
            columns: ["leader_1_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "home_groups_leader_2_id_fkey"
            columns: ["leader_2_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "home_groups_sector_id_fkey"
            columns: ["sector_id"]
            isOneToOne: false
            referencedRelation: "sectors"
            referencedColumns: ["id"]
          },
        ]
      }
      media_resources: {
        Row: {
          category: string | null
          created_at: string | null
          description: string | null
          id: string
          series_name: string | null
          title: string
          type: Database["public"]["Enums"]["media_type"]
          url: string
        }
        Insert: {
          category?: string | null
          created_at?: string | null
          description?: string | null
          id?: string
          series_name?: string | null
          title: string
          type: Database["public"]["Enums"]["media_type"]
          url: string
        }
        Update: {
          category?: string | null
          created_at?: string | null
          description?: string | null
          id?: string
          series_name?: string | null
          title?: string
          type?: Database["public"]["Enums"]["media_type"]
          url?: string
        }
        Relationships: []
      }
      posts: {
        Row: {
          author_id: string | null
          category: Database["public"]["Enums"]["post_category"]
          content: string
          created_at: string | null
          event_end_date: string | null
          event_start_date: string | null
          id: string
          image_urls: string[] | null
          is_published: boolean | null
          title: string
        }
        Insert: {
          author_id?: string | null
          category?: Database["public"]["Enums"]["post_category"]
          content: string
          created_at?: string | null
          event_end_date?: string | null
          event_start_date?: string | null
          id?: string
          image_urls?: string[] | null
          is_published?: boolean | null
          title: string
        }
        Update: {
          author_id?: string | null
          category?: Database["public"]["Enums"]["post_category"]
          content?: string
          created_at?: string | null
          event_end_date?: string | null
          event_start_date?: string | null
          id?: string
          image_urls?: string[] | null
          is_published?: boolean | null
          title?: string
        }
        Relationships: [
          {
            foreignKeyName: "posts_author_id_fkey"
            columns: ["author_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      profiles: {
        Row: {
          address_city: string | null
          address_complement: string | null
          address_neighborhood: string | null
          address_number: string | null
          address_state: string | null
          address_street: string | null
          address_zip_code: string | null
          avatar_url: string | null
          baptism_date: string | null
          birth_date: string | null
          can_post: boolean | null
          cpf: string | null
          created_at: string | null
          dependents_count: number
          discipler_id: string | null
          drivers_license: string
          education_level: string
          email: string | null
          employment_status: string
          father_id: string | null
          full_name: string
          gender: string | null
          home_group_id: string | null
          household_income: string
          housing_status: string
          id: string
          is_deacon: boolean | null
          is_dev: boolean | null
          is_presbyter: boolean | null
          marital_status: string | null
          mother_id: string | null
          occupation: string
          phone: string | null
          spouse_id: string | null
          user_id: string | null
        }
        Insert: {
          address_city?: string | null
          address_complement?: string | null
          address_neighborhood?: string | null
          address_number?: string | null
          address_state?: string | null
          address_street?: string | null
          address_zip_code?: string | null
          avatar_url?: string | null
          baptism_date?: string | null
          birth_date?: string | null
          can_post?: boolean | null
          cpf?: string | null
          created_at?: string | null
          dependents_count?: number
          discipler_id?: string | null
          drivers_license: string
          education_level: string
          email?: string | null
          employment_status: string
          father_id?: string | null
          full_name: string
          gender?: string | null
          home_group_id?: string | null
          household_income: string
          housing_status: string
          id?: string
          is_deacon?: boolean | null
          is_dev?: boolean | null
          is_presbyter?: boolean | null
          marital_status?: string | null
          mother_id?: string | null
          occupation: string
          phone?: string | null
          spouse_id?: string | null
          user_id?: string | null
        }
        Update: {
          address_city?: string | null
          address_complement?: string | null
          address_neighborhood?: string | null
          address_number?: string | null
          address_state?: string | null
          address_street?: string | null
          address_zip_code?: string | null
          avatar_url?: string | null
          baptism_date?: string | null
          birth_date?: string | null
          can_post?: boolean | null
          cpf?: string | null
          created_at?: string | null
          dependents_count?: number
          discipler_id?: string | null
          drivers_license?: string
          education_level?: string
          email?: string | null
          employment_status?: string
          father_id?: string | null
          full_name?: string
          gender?: string | null
          home_group_id?: string | null
          household_income?: string
          housing_status?: string
          id?: string
          is_deacon?: boolean | null
          is_dev?: boolean | null
          is_presbyter?: boolean | null
          marital_status?: string | null
          mother_id?: string | null
          occupation?: string
          phone?: string | null
          spouse_id?: string | null
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "profiles_discipler_id_fkey"
            columns: ["discipler_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "profiles_father_id_fkey"
            columns: ["father_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "profiles_home_group_id_fkey"
            columns: ["home_group_id"]
            isOneToOne: false
            referencedRelation: "home_groups"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "profiles_mother_id_fkey"
            columns: ["mother_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "profiles_spouse_id_fkey"
            columns: ["spouse_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      registrations: {
        Row: {
          created_at: string | null
          custom_responses: Json | null
          form_submission_id: string | null
          guest_data: Json | null
          id: string
          notes: string | null
          paid: boolean | null
          payment_method: string | null
          payment_reference: string | null
          profile_id: string | null
          retreat_id: string | null
          room_allocation: string | null
        }
        Insert: {
          created_at?: string | null
          custom_responses?: Json | null
          form_submission_id?: string | null
          guest_data?: Json | null
          id?: string
          notes?: string | null
          paid?: boolean | null
          payment_method?: string | null
          payment_reference?: string | null
          profile_id?: string | null
          retreat_id?: string | null
          room_allocation?: string | null
        }
        Update: {
          created_at?: string | null
          custom_responses?: Json | null
          form_submission_id?: string | null
          guest_data?: Json | null
          id?: string
          notes?: string | null
          paid?: boolean | null
          payment_method?: string | null
          payment_reference?: string | null
          profile_id?: string | null
          retreat_id?: string | null
          room_allocation?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "registrations_form_submission_id_fkey"
            columns: ["form_submission_id"]
            isOneToOne: false
            referencedRelation: "form_submissions"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "registrations_profile_id_fkey"
            columns: ["profile_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "registrations_retreat_id_fkey"
            columns: ["retreat_id"]
            isOneToOne: false
            referencedRelation: "retreats"
            referencedColumns: ["id"]
          },
        ]
      }
      retreats: {
        Row: {
          created_at: string | null
          description: string | null
          end_date: string | null
          form_id: string | null
          form_model: Database["public"]["Enums"]["retreat_form_model"] | null
          id: string
          image_url: string | null
          location_text: string | null
          max_participants: number | null
          price: number | null
          registration_deadline: string | null
          start_date: string | null
          status: string | null
          title: string
        }
        Insert: {
          created_at?: string | null
          description?: string | null
          end_date?: string | null
          form_id?: string | null
          form_model?: Database["public"]["Enums"]["retreat_form_model"] | null
          id?: string
          image_url?: string | null
          location_text?: string | null
          max_participants?: number | null
          price?: number | null
          registration_deadline?: string | null
          start_date?: string | null
          status?: string | null
          title: string
        }
        Update: {
          created_at?: string | null
          description?: string | null
          end_date?: string | null
          form_id?: string | null
          form_model?: Database["public"]["Enums"]["retreat_form_model"] | null
          id?: string
          image_url?: string | null
          location_text?: string | null
          max_participants?: number | null
          price?: number | null
          registration_deadline?: string | null
          start_date?: string | null
          status?: string | null
          title?: string
        }
        Relationships: [
          {
            foreignKeyName: "retreats_form_id_fkey"
            columns: ["form_id"]
            isOneToOne: false
            referencedRelation: "forms"
            referencedColumns: ["id"]
          },
        ]
      }
      sectors: {
        Row: {
          created_at: string | null
          id: string
          name: string
        }
        Insert: {
          created_at?: string | null
          id?: string
          name: string
        }
        Update: {
          created_at?: string | null
          id?: string
          name?: string
        }
        Relationships: []
      }
      studies: {
        Row: {
          created_at: string | null
          created_by: string | null
          description: string | null
          id: string
          title: string
        }
        Insert: {
          created_at?: string | null
          created_by?: string | null
          description?: string | null
          id?: string
          title: string
        }
        Update: {
          created_at?: string | null
          created_by?: string | null
          description?: string | null
          id?: string
          title?: string
        }
        Relationships: [
          {
            foreignKeyName: "studies_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      study_steps: {
        Row: {
          created_at: string | null
          id: string
          media_resource_id: string
          sort_order: number
          study_id: string
        }
        Insert: {
          created_at?: string | null
          id?: string
          media_resource_id: string
          sort_order: number
          study_id: string
        }
        Update: {
          created_at?: string | null
          id?: string
          media_resource_id?: string
          sort_order?: number
          study_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "study_steps_media_resource_id_fkey"
            columns: ["media_resource_id"]
            isOneToOne: false
            referencedRelation: "media_resources"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "study_steps_study_id_fkey"
            columns: ["study_id"]
            isOneToOne: false
            referencedRelation: "studies"
            referencedColumns: ["id"]
          },
        ]
      }
      user_study_progress: {
        Row: {
          completed_at: string | null
          id: string
          profile_id: string
          step_id: string
          study_id: string
        }
        Insert: {
          completed_at?: string | null
          id?: string
          profile_id: string
          step_id: string
          study_id: string
        }
        Update: {
          completed_at?: string | null
          id?: string
          profile_id?: string
          step_id?: string
          study_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_study_progress_profile_id_fkey"
            columns: ["profile_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_study_progress_step_id_fkey"
            columns: ["step_id"]
            isOneToOne: false
            referencedRelation: "study_steps"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_study_progress_study_id_fkey"
            columns: ["study_id"]
            isOneToOne: false
            referencedRelation: "studies"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      check_cpf_registration: {
        Args: { p_cpf: string }
        Returns: {
          address_city: string
          address_complement: string
          address_neighborhood: string
          address_number: string
          address_state: string
          address_street: string
          address_zip_code: string
          baptism_date: string
          birth_date: string
          dependents_count: number
          drivers_license: string
          education_level: string
          email: string
          employment_status: string
          exists_profile: boolean
          full_name: string
          gender: string
          has_baptism_date: boolean
          household_income: string
          housing_status: string
          is_linked: boolean
          marital_status: string
          occupation: string
          phone: string
          profile_id: string
        }[]
      }
    }
    Enums: {
      media_type: "video" | "pdf" | "markdown"
      post_category:
        | "noticia"
        | "oracao"
        | "diaconato"
        | "obra"
        | "aviso"
        | "evento"
      retreat_form_model: "geral" | "socioeconomico" | "logistica"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {
      media_type: ["video", "pdf", "markdown"],
      post_category: [
        "noticia",
        "oracao",
        "diaconato",
        "obra",
        "aviso",
        "evento",
      ],
      retreat_form_model: ["geral", "socioeconomico", "logistica"],
    },
  },
} as const
