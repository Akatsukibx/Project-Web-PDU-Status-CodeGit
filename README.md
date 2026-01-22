# PDU Monitoring System

This project contains a Node.js Backend and a Vite + React Frontend.
The Frontend is built and served by the Backend, allowing you to access the entire application from a single URL.

## Prerequisites
- Node.js (v16+)
- PostgreSQL Database

## Quick Start (Single URL)
1. **Database**: Ensure PostgreSQL is running and `pdu_monitoring_full.sql` is imported.
2. **Start Server**:
    ```bash
    cd backend
    npm install
    cp .env.example .env
    # Edit .env with your database credentials
    npm start
    ```
3. **Access**: Open `http://localhost:8000` in your browser.

## Development

### Re-building Frontend
If you modify code in `/frontend`, you must rebuild it for the changes to appear on port 8000:
```bash
cd frontend
npm run build
```

### Running Separately (Dev Mode)
For hot-reloading frontend development:
1. Start Backend: `cd backend && npm start` (Port 8000)
2. Start Frontend: `cd frontend && npm run dev` (Port 5173)
