-- Update PDU-PKY-2 (ID 5) Outlets
UPDATE pdu_outlet SET status = 'on', name = 'Outlet 1' WHERE pdu_id = 5 AND outlet_no = 1;
UPDATE pdu_outlet SET status = 'off', name = 'Outlet 2' WHERE pdu_id = 5 AND outlet_no = 2;
UPDATE pdu_outlet SET status = 'off', name = 'Outlet 3' WHERE pdu_id = 5 AND outlet_no = 3;
UPDATE pdu_outlet SET status = 'off', name = 'Outlet 4' WHERE pdu_id = 5 AND outlet_no = 4;
UPDATE pdu_outlet SET status = 'off', name = 'Outlet 5' WHERE pdu_id = 5 AND outlet_no = 5;
UPDATE pdu_outlet SET status = 'on', name = 'Outlet 6' WHERE pdu_id = 5 AND outlet_no = 6;
UPDATE pdu_outlet SET status = 'off', name = 'Outlet 7' WHERE pdu_id = 5 AND outlet_no = 7;
UPDATE pdu_outlet SET status = 'on', name = 'Outlet 8' WHERE pdu_id = 5 AND outlet_no = 8;
