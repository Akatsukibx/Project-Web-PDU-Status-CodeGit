-- 1. Update existing ICT-1 to ICT Zone
UPDATE pdu SET location = 'ICT Zone' WHERE id = 1;

-- 2. Add PKY Zone PDU (Mock)
INSERT INTO pdu (name, model, ip_address, location, status, brand) 
VALUES ('PDU-PKY-1', 'APC Rack PDU', '10.220.71.35', 'PKY Zone', 'online', 'APC');

-- 3. Add PN Zone PDU (Mock)
INSERT INTO pdu (name, model, ip_address, location, status, brand) 
VALUES ('PDU-PN-1', 'APC Rack PDU', '10.220.71.36', 'PN Zone', 'online', 'APC');

-- 4. Add EC Zone PDU (Mock)
INSERT INTO pdu (name, model, ip_address, location, status, brand) 
VALUES ('PDU-EC-1', 'APC Rack PDU', '10.220.71.37', 'EC Zone', 'offline', 'APC');
