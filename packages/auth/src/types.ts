// packages/auth/src/types.ts
// Type minimal extrait de @repo/database pour éviter l'erreur TS6307
export interface Database {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string
          role: string | null
          [key: string]: any
        }
      }
      [key: string]: any
    }
  }
}
