require('dotenv').config();
const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 8000;

// Middleware
app.use(cors());
app.use(express.json());

// Database Connection
const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
});

pool.on('error', (err) => {
  console.error('Unexpected error on idle client', err);
  process.exit(-1);
});

// Routes

// GET /api/pdu/list
// Returns a list of PDUs for the selector
app.get('/api/pdu/list', async (req, res) => {
  try {
    const query = `
      SELECT id, name, location, status, model
      FROM pdu
      ORDER BY id ASC
    `;
    const { rows } = await pool.query(query);
    res.json(rows);
  } catch (err) {
    console.error('Error fetching PDU list:', err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});



// GET /api/pdus/:id/monitor
// Unified endpoint for PDU monitoring
app.get('/api/pdus/:id/monitor', async (req, res) => {
  const pduId = req.params.id;

  try {
    // 1. Fetch PDU Details
    const pduQuery = 'SELECT * FROM pdu WHERE id = $1';
    const pduResult = await pool.query(pduQuery, [pduId]);

    if (pduResult.rows.length === 0) {
      return res.status(404).json({ error: 'PDU not found' });
    }
    const pdu = pduResult.rows[0];

    // 2. Fetch Latest Power Status
    const powerQuery = `
      SELECT * FROM pdu_power_status 
      WHERE pdu_id = $1 
      ORDER BY timestamp DESC 
      LIMIT 1
    `;
    const powerResult = await pool.query(powerQuery, [pduId]);
    const power = powerResult.rows[0] || {};

    // 3. Fetch Active Alarms (Summary)
    const alarmQuery = `
      SELECT count(*) as count 
      FROM pdu_event_log 
      WHERE pdu_id = $1 
        AND event_type IN ('alarm', 'overload', 'breaker') 
        AND cleared_at IS NULL
    `;
    const alarmResult = await pool.query(alarmQuery, [pduId]);
    const alarmCount = parseInt(alarmResult.rows[0].count, 10);

    const pduAlarmQuery = 'SELECT * FROM pdu_alarm WHERE pdu_id = $1 LIMIT 1';
    const pduAlarmResult = await pool.query(pduAlarmQuery, [pduId]);
    const pduAlarm = pduAlarmResult.rows[0] || {};


    // 4. Fetch Outlets
    const outletQuery = `
      SELECT outlet_no, name, status, current
      FROM pdu_outlet
      WHERE pdu_id = $1
      ORDER BY outlet_no ASC
    `;
    const outletResult = await pool.query(outletQuery, [pduId]);

    // Construct Response
    const response = {
      pdu_id: pdu.id,
      name: pdu.name,
      model: pdu.model,
      location: pdu.location,
      ip_address: pdu.ip_address,
      timestamp: power.timestamp || new Date().toISOString(),

      metrics: {
        load_current_a: power.current ? parseFloat(power.current) : null,
        max_current_a: power.max_current ? parseFloat(power.max_current) : null,
        load_percent: power.load_percent ? parseFloat(power.load_percent) : null,
        voltage_v: null,
        power_w: null,
        energy_kwh: null,
        frequency_hz: null,
        pf: null,
        temp_c: null,
      },

      status: {
        connection_status: pdu.status || 'offline',
        alarm_active: alarmCount > 0 || (pduAlarm.has_alarm === true),
        alarm_count: alarmCount,
        uptime: pdu.uptime
      },

      outlets: outletResult.rows.map(o => ({
        id: o.outlet_no,
        name: o.name,
        status: o.status,
        current: parseFloat(o.current)
      }))
    };

    res.json(response);

  } catch (err) {
    console.error('Error fetching PDU monitor data:', err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Serve static files from Frontend
const path = require('path');
app.use(express.static(path.join(__dirname, '../frontend/dist')));

// Catch-all route to serve Frontend's index.html
app.get(/(.*)/, (req, res) => {
  res.sendFile(path.join(__dirname, '../frontend/dist', 'index.html'));
});

app.listen(PORT, () => {
  console.log(`Backend server running on http://localhost:${PORT}`);
});
