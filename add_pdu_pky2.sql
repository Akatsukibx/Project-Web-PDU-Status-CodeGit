-- 1. Insert PDU-PKY-2
-- Using next available ID (assuming serial/autoincrement, but specifying explicitly if needed based on schema, though ID is usually integer)
-- Let's rely on Sequence if exists or just pick a safe ID like 5.
-- Schema check showed 'id integer NOT NULL', probably manual. Current max is 4.
INSERT INTO pdu (id, name, model, ip_address, location, status, brand, uptime, created_at, updated_at) 
VALUES (5, 'PDU-PKY-2', 'APC Rack PDU 2G', '10.220.71.38', 'PKY Zone', 'online', 'APC', '15 days, 4:20:00', NOW(), NOW());

-- 2. Insert Power Status (for Load Status & Metrics)
INSERT INTO pdu_power_status (pdu_id, current, max_current, load_percent, timestamp)
VALUES (5, 4.50, 16.00, 28.12, NOW());

-- 3. Insert Outlets (8 outlets like PKY-1)
INSERT INTO pdu_outlet (pdu_id, outlet_no, name, status, current) VALUES
(5, 1, 'Server-A', 'on', 1.20),
(5, 2, 'Server-B', 'on', 1.10),
(5, 3, 'Switch-Core', 'on', 0.85),
(5, 4, 'Router', 'on', 0.50),
(5, 5, 'Backup-NAS', 'on', 0.85),
(5, 6, 'Spare', 'off', 0.00),
(5, 7, 'Spare', 'off', 0.00),
(5, 8, 'Spare', 'off', 0.00);

-- 4. No alarms (optional, but good to interpret as clear)
-- No insert needed for pdu_event_log for 'alarm_active: false' logic (count=0)
