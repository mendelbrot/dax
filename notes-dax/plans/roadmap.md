# Dax Project Roadmap

## Active Tasks
- [x] Establish Project Workflow
    - [x] Create folder structure (plans, knowledge, dev-logs)
    - [x] Update GEMINI.md with workflow documentation
    - [x] Define "Log:" convention
- [ ] Implement Real-time Sync Support
    - [ ] **Backend:** Verify/Add `transient_client_id` to tables
    - [ ] **Backend:** Verify/Configure `REPLICA IDENTITY` for delete logging
    - [ ] **Frontend:** Port "Expiring Set" logic (echo cancellation for deletes)
    - [ ] **Frontend:** Refactor broken sync code (move to `NotifierProvider`)

## Backlog
- [ ] **Frontend:** Restructure folder organization
- [ ] **Collaboration:** Investigate CRDTs (Yjs/Automerge) for simultaneous editing

## Completed
- [x] Archive old notes