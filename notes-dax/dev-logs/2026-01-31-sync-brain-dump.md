# Sync Architecture & Current Status - Jan 31, 2026

## Raw Input
> the major item im grappling with is making changes sync across multiple devices. We're using supabase realtime notifications of database changes, we're creating a costom index with the info the frontend needs for this, and changed a postgres setting so this index is logged for changes. We're also adding a field to vault and entries tables called transient_client_id, that is a random uuid provided by the frontent so that it can filter out changes origionating from itself. (for it's own changes it updates internally to reduce lag). As well since delete log doens't include the transient_client_id of the deleter, there's a a particular procedure where if it's a delete, instead of filtering out this id, it adds the id of the deleted item in the frontend to an expiring set, and ignores ides in this set. The expiring set is an item i worked on in the gemini app (hence my problem with fragmented, non-centralized information) I can copy it over at some point. Also, im new to reverpod and not totally clear on deferences like Provider vs ChangeNotifierProvider, and not sure which to use. I currently have some broken partly written code in the frontend, and i think i might have some missing SQL code for this feature  as well. In the long term, im also thinking about restructuring the frontend folder structure and entire organization of the app. And an area that will be especially challenging is having the note editing synce in real time well enough such that in principal the same note could be simultaniusly edited fron two devices. That's where i eventually want to get, but one step at a time. Please record this to the dev log and give me your feedback

---

## AI Summary & Analysis

### Overview
We are implementing real-time synchronization across devices using Supabase Realtime.

### Technical Approach
1.  **Supabase Realtime:** Listening to database changes.
2.  **Custom Index:** Postgres settings changed so a custom index with frontend-needed info is logged.
3.  **Echo Cancellation (`transient_client_id`):**
    *   Vaults and entries tables have a `transient_client_id` column (UUID).
    *   Frontend generates a random ID per session.
    *   Frontend sends this ID with mutations.
    *   Frontend filters out incoming Realtime events matching its own ID (since it updates optimistically).
4.  **Deletion Handling:**
    *   Delete logs don't include the `transient_client_id` of the deleter.
    *   **Strategy:** Frontend adds the ID of the deleted item to a local "Expiring Set". Incoming delete events for IDs in this set are ignored.
    *   **Status:** The "Expiring Set" logic exists in a different project (Gemini app) and needs porting.

### Current State
*   **Frontend:** Broken / partly written.
*   **Backend:** Potentially missing SQL for `transient_client_id` columns or configuration.
*   **Knowledge Gaps:**
    *   Riverpod: Confusion between `Provider`, `ChangeNotifierProvider`, etc.
*   **Long-term Goals:**
    *   Frontend folder restructuring.
    *   True simultaneous collaborative editing (Google Docs style).

### Immediate Actions Needed
*   Verify/Fix SQL schema.
*   Port "Expiring Set" logic.
*   Fix broken frontend sync logic.
*   Clarify Riverpod architecture.