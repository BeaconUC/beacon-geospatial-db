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
    PostgrestVersion: "13.0.5"
  }
  public: {
    Tables: {
      affected_areas: {
        Row: {
          barangay_id: number
          created_at: string
          id: number
          outage_id: number
        }
        Insert: {
          barangay_id: number
          created_at?: string
          id?: number
          outage_id: number
        }
        Update: {
          barangay_id?: number
          created_at?: string
          id?: number
          outage_id?: number
        }
        Relationships: [
          {
            foreignKeyName: "affected_areas_barangay_id_fkey"
            columns: ["barangay_id"]
            isOneToOne: false
            referencedRelation: "barangays"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "affected_areas_outage_id_fkey"
            columns: ["outage_id"]
            isOneToOne: false
            referencedRelation: "outage_summary"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "affected_areas_outage_id_fkey"
            columns: ["outage_id"]
            isOneToOne: false
            referencedRelation: "outages"
            referencedColumns: ["id"]
          },
        ]
      }
      api_keys: {
        Row: {
          api_key: string
          created_at: string
          created_by: number | null
          expires_at: string | null
          id: number
          is_active: boolean
          name: string
          public_id: string
          rate_limit_per_minute: number | null
          secret_key: string | null
          service_name: string | null
        }
        Insert: {
          api_key: string
          created_at?: string
          created_by?: number | null
          expires_at?: string | null
          id?: number
          is_active?: boolean
          name: string
          public_id?: string
          rate_limit_per_minute?: number | null
          secret_key?: string | null
          service_name?: string | null
        }
        Update: {
          api_key?: string
          created_at?: string
          created_by?: number | null
          expires_at?: string | null
          id?: number
          is_active?: boolean
          name?: string
          public_id?: string
          rate_limit_per_minute?: number | null
          secret_key?: string | null
          service_name?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "api_keys_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      assignments: {
        Row: {
          assigned_at: string
          crew_id: number
          id: number
          notes: string | null
          outage_id: number
          public_id: string
          status: Database["public"]["Enums"]["assignment_status"]
          updated_at: string | null
        }
        Insert: {
          assigned_at?: string
          crew_id: number
          id?: number
          notes?: string | null
          outage_id: number
          public_id?: string
          status?: Database["public"]["Enums"]["assignment_status"]
          updated_at?: string | null
        }
        Update: {
          assigned_at?: string
          crew_id?: number
          id?: number
          notes?: string | null
          outage_id?: number
          public_id?: string
          status?: Database["public"]["Enums"]["assignment_status"]
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "assignments_crew_id_fkey"
            columns: ["crew_id"]
            isOneToOne: false
            referencedRelation: "crews"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "assignments_outage_id_fkey"
            columns: ["outage_id"]
            isOneToOne: false
            referencedRelation: "outage_summary"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "assignments_outage_id_fkey"
            columns: ["outage_id"]
            isOneToOne: false
            referencedRelation: "outages"
            referencedColumns: ["id"]
          },
        ]
      }
      barangays: {
        Row: {
          boundary: unknown
          city_id: number
          created_at: string
          feeder_id: number | null
          id: number
          name: string
          population: number | null
          population_year: number | null
          public_id: string
          updated_at: string | null
        }
        Insert: {
          boundary: unknown
          city_id: number
          created_at?: string
          feeder_id?: number | null
          id?: number
          name: string
          population?: number | null
          population_year?: number | null
          public_id?: string
          updated_at?: string | null
        }
        Update: {
          boundary?: unknown
          city_id?: number
          created_at?: string
          feeder_id?: number | null
          id?: number
          name?: string
          population?: number | null
          population_year?: number | null
          public_id?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "barangays_city_id_fkey"
            columns: ["city_id"]
            isOneToOne: false
            referencedRelation: "cities"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "barangays_feeder_id_fkey"
            columns: ["feeder_id"]
            isOneToOne: false
            referencedRelation: "feeders"
            referencedColumns: ["id"]
          },
        ]
      }
      cities: {
        Row: {
          boundary: unknown
          created_at: string
          id: number
          name: string
          population: number | null
          population_year: number | null
          province_id: number
          public_id: string
          updated_at: string | null
        }
        Insert: {
          boundary: unknown
          created_at?: string
          id?: number
          name: string
          population?: number | null
          population_year?: number | null
          province_id: number
          public_id?: string
          updated_at?: string | null
        }
        Update: {
          boundary?: unknown
          created_at?: string
          id?: number
          name?: string
          population?: number | null
          population_year?: number | null
          province_id?: number
          public_id?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "cities_province_id_fkey"
            columns: ["province_id"]
            isOneToOne: false
            referencedRelation: "provinces"
            referencedColumns: ["id"]
          },
        ]
      }
      crews: {
        Row: {
          created_at: string
          crew_type: Database["public"]["Enums"]["crew_type"]
          description: string | null
          id: number
          name: string
          public_id: string
          updated_at: string | null
        }
        Insert: {
          created_at?: string
          crew_type?: Database["public"]["Enums"]["crew_type"]
          description?: string | null
          id?: number
          name: string
          public_id?: string
          updated_at?: string | null
        }
        Update: {
          created_at?: string
          crew_type?: Database["public"]["Enums"]["crew_type"]
          description?: string | null
          id?: number
          name?: string
          public_id?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      feeders: {
        Row: {
          boundary: unknown
          created_at: string
          feeder_number: number
          id: number
          public_id: string
          updated_at: string | null
        }
        Insert: {
          boundary: unknown
          created_at?: string
          feeder_number: number
          id?: number
          public_id?: string
          updated_at?: string | null
        }
        Update: {
          boundary?: unknown
          created_at?: string
          feeder_number?: number
          id?: number
          public_id?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      outage_reports: {
        Row: {
          description: string | null
          id: number
          image_url: string | null
          linked_outage_id: number | null
          location: unknown
          public_id: string
          reported_at: string
          reported_by: number | null
          status: Database["public"]["Enums"]["report_status"]
          updated_at: string | null
        }
        Insert: {
          description?: string | null
          id?: number
          image_url?: string | null
          linked_outage_id?: number | null
          location: unknown
          public_id?: string
          reported_at?: string
          reported_by?: number | null
          status?: Database["public"]["Enums"]["report_status"]
          updated_at?: string | null
        }
        Update: {
          description?: string | null
          id?: number
          image_url?: string | null
          linked_outage_id?: number | null
          location?: unknown
          public_id?: string
          reported_at?: string
          reported_by?: number | null
          status?: Database["public"]["Enums"]["report_status"]
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "outage_reports_linked_outage_id_fkey"
            columns: ["linked_outage_id"]
            isOneToOne: false
            referencedRelation: "outage_summary"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "outage_reports_linked_outage_id_fkey"
            columns: ["linked_outage_id"]
            isOneToOne: false
            referencedRelation: "outages"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "outage_reports_reported_by_fkey"
            columns: ["reported_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      outage_updates: {
        Row: {
          created_at: string
          description: string | null
          id: number
          new_status: Database["public"]["Enums"]["outage_status"]
          old_status: Database["public"]["Enums"]["outage_status"]
          outage_id: number
          public_id: string
          user_id: number
        }
        Insert: {
          created_at?: string
          description?: string | null
          id?: number
          new_status: Database["public"]["Enums"]["outage_status"]
          old_status: Database["public"]["Enums"]["outage_status"]
          outage_id: number
          public_id?: string
          user_id: number
        }
        Update: {
          created_at?: string
          description?: string | null
          id?: number
          new_status?: Database["public"]["Enums"]["outage_status"]
          old_status?: Database["public"]["Enums"]["outage_status"]
          outage_id?: number
          public_id?: string
          user_id?: number
        }
        Relationships: [
          {
            foreignKeyName: "outage_updates_outage_id_fkey"
            columns: ["outage_id"]
            isOneToOne: false
            referencedRelation: "outage_summary"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "outage_updates_outage_id_fkey"
            columns: ["outage_id"]
            isOneToOne: false
            referencedRelation: "outages"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "outage_updates_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      outages: {
        Row: {
          actual_restoration_time: string | null
          confidence_percentage: number | null
          confirmed_by: number | null
          created_at: string
          description: string | null
          estimated_affected_population: number | null
          estimated_restoration_time: string | null
          id: number
          number_of_reports: number | null
          outage_type: Database["public"]["Enums"]["outage_type"]
          public_id: string
          resolved_by: number | null
          start_time: string | null
          status: Database["public"]["Enums"]["outage_status"]
          title: string | null
          updated_at: string | null
        }
        Insert: {
          actual_restoration_time?: string | null
          confidence_percentage?: number | null
          confirmed_by?: number | null
          created_at?: string
          description?: string | null
          estimated_affected_population?: number | null
          estimated_restoration_time?: string | null
          id?: number
          number_of_reports?: number | null
          outage_type?: Database["public"]["Enums"]["outage_type"]
          public_id?: string
          resolved_by?: number | null
          start_time?: string | null
          status?: Database["public"]["Enums"]["outage_status"]
          title?: string | null
          updated_at?: string | null
        }
        Update: {
          actual_restoration_time?: string | null
          confidence_percentage?: number | null
          confirmed_by?: number | null
          created_at?: string
          description?: string | null
          estimated_affected_population?: number | null
          estimated_restoration_time?: string | null
          id?: number
          number_of_reports?: number | null
          outage_type?: Database["public"]["Enums"]["outage_type"]
          public_id?: string
          resolved_by?: number | null
          start_time?: string | null
          status?: Database["public"]["Enums"]["outage_status"]
          title?: string | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "outages_confirmed_by_fkey"
            columns: ["confirmed_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "outages_resolved_by_fkey"
            columns: ["resolved_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      profile_settings: {
        Row: {
          created_at: string
          dynamic_color: boolean
          extra_settings: Json
          font_scale: number
          id: number
          language: string
          profile_id: number | null
          reduce_motion: boolean
          theme: Database["public"]["Enums"]["themes"]
          updated_at: string | null
        }
        Insert: {
          created_at?: string
          dynamic_color?: boolean
          extra_settings?: Json
          font_scale?: number
          id?: number
          language?: string
          profile_id?: number | null
          reduce_motion?: boolean
          theme?: Database["public"]["Enums"]["themes"]
          updated_at?: string | null
        }
        Update: {
          created_at?: string
          dynamic_color?: boolean
          extra_settings?: Json
          font_scale?: number
          id?: number
          language?: string
          profile_id?: number | null
          reduce_motion?: boolean
          theme?: Database["public"]["Enums"]["themes"]
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "profile_settings_profile_id_fkey"
            columns: ["profile_id"]
            isOneToOne: true
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      profiles: {
        Row: {
          created_at: string
          first_name: string
          id: number
          last_name: string
          phone_number: string | null
          public_id: string
          role: Database["public"]["Enums"]["roles"]
          updated_at: string | null
          user_id: string
        }
        Insert: {
          created_at?: string
          first_name: string
          id?: number
          last_name: string
          phone_number?: string | null
          public_id?: string
          role?: Database["public"]["Enums"]["roles"]
          updated_at?: string | null
          user_id: string
        }
        Update: {
          created_at?: string
          first_name?: string
          id?: number
          last_name?: string
          phone_number?: string | null
          public_id?: string
          role?: Database["public"]["Enums"]["roles"]
          updated_at?: string | null
          user_id?: string
        }
        Relationships: []
      }
      provinces: {
        Row: {
          boundary: unknown
          created_at: string
          id: number
          name: string
          population: number | null
          population_year: number | null
          public_id: string
          updated_at: string | null
        }
        Insert: {
          boundary: unknown
          created_at?: string
          id?: number
          name: string
          population?: number | null
          population_year?: number | null
          public_id?: string
          updated_at?: string | null
        }
        Update: {
          boundary?: unknown
          created_at?: string
          id?: number
          name?: string
          population?: number | null
          population_year?: number | null
          public_id?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      system_config: {
        Row: {
          description: string | null
          id: number
          key: string
          public_id: string
          updated_at: string | null
          updated_by: number | null
          value: string
        }
        Insert: {
          description?: string | null
          id?: number
          key: string
          public_id?: string
          updated_at?: string | null
          updated_by?: number | null
          value: string
        }
        Update: {
          description?: string | null
          id?: number
          key?: string
          public_id?: string
          updated_at?: string | null
          updated_by?: number | null
          value?: string
        }
        Relationships: [
          {
            foreignKeyName: "system_config_updated_by_fkey"
            columns: ["updated_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      weather_data: {
        Row: {
          atmospheric_pressure: number | null
          city_id: number
          condition_description: string | null
          condition_main: string | null
          created_at: string
          feels_like: number | null
          humidity: number | null
          id: number
          precipitation: number | null
          public_id: string
          recorded_at: string
          temperature: number
          wind_speed: number | null
        }
        Insert: {
          atmospheric_pressure?: number | null
          city_id: number
          condition_description?: string | null
          condition_main?: string | null
          created_at?: string
          feels_like?: number | null
          humidity?: number | null
          id?: number
          precipitation?: number | null
          public_id?: string
          recorded_at: string
          temperature: number
          wind_speed?: number | null
        }
        Update: {
          atmospheric_pressure?: number | null
          city_id?: number
          condition_description?: string | null
          condition_main?: string | null
          created_at?: string
          feels_like?: number | null
          humidity?: number | null
          id?: number
          precipitation?: number | null
          public_id?: string
          recorded_at?: string
          temperature?: number
          wind_speed?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "weather_data_city_id_fkey"
            columns: ["city_id"]
            isOneToOne: false
            referencedRelation: "cities"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      outage_summary: {
        Row: {
          affected_barangay_count: number | null
          estimated_population_affected: number | null
          id: number | null
          public_id: string | null
          status: Database["public"]["Enums"]["outage_status"] | null
        }
        Relationships: []
      }
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      assignment_status:
        | "assigned"
        | "en_route"
        | "on_site"
        | "paused"
        | "completed"
        | "cancelled"
      crew_type: "team" | "individual"
      outage_status: "unverified" | "verified" | "being_resolved" | "resolved"
      outage_type: "unscheduled" | "scheduled" | "emergency"
      report_status:
        | "unprocessed"
        | "processed_as_new_outage"
        | "processed_as_duplicate"
        | "archived_as_isolated"
      roles: "user" | "crew" | "admin"
      themes: "light" | "dark" | "system"
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
      assignment_status: [
        "assigned",
        "en_route",
        "on_site",
        "paused",
        "completed",
        "cancelled",
      ],
      crew_type: ["team", "individual"],
      outage_status: ["unverified", "verified", "being_resolved", "resolved"],
      outage_type: ["unscheduled", "scheduled", "emergency"],
      report_status: [
        "unprocessed",
        "processed_as_new_outage",
        "processed_as_duplicate",
        "archived_as_isolated",
      ],
      roles: ["user", "crew", "admin"],
      themes: ["light", "dark", "system"],
    },
  },
} as const
