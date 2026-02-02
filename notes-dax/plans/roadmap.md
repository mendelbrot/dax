# Dax Project Roadmap

## Active Tasks
- [x] **Refactoring:** Convert Frontend IDs to match Database types (`int` for bigints, `String` for UUIDs)
- [ ] **Architecture:** Investigate interaction between Data Layers and define a clean division of responsibility
- [ ] Implement Real-time Sync Support
    - [x] **Backend:** Verify/Add `transient_client_id` to tables
    - [x] **Backend:** Verify/Configure `REPLICA IDENTITY` for delete logging
    - [ ] **Frontend:** Port "Expiring Set" logic (echo cancellation for deletes)
    - [ ] **Frontend:** Refactor broken sync code (move to `NotifierProvider`)

## Backlog
- [ ] **Frontend:** Restructure folder organization
- [ ] **Collaboration:** Investigate CRDTs (Yjs/Automerge) for simultaneous editing

## Completed
- [x] Archive old notes