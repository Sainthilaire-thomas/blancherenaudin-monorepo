// packages/newsletter/src/types.ts
export interface Database {
  public: {
    Tables: {
      newsletter_subscribers: {
        Row: {
          id: string
          email: string
          first_name: string | null
          [key: string]: any
        }
      }
      [key: string]: any
    }
  }
}
