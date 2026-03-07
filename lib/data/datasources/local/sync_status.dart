/// Enum indicating the local Drift record's cloud-sync state.
/// Drift maps this to an integer column via [intEnum].
///
/// - [synced]        (0): Row is in sync with the Supabase cloud.
/// - [pendingInsert] (1): Row was created offline and must be uploaded.
/// - [pendingUpdate] (2): Row was modified offline and must be re-synced.
/// - [pendingDelete] (3): Row was deleted offline; cloud copy must be removed.
enum SyncStatus {
  synced,
  pendingInsert,
  pendingUpdate,
  pendingDelete,
}
