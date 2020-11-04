INSERT INTO functional_areas (functional_area_name) VALUES('Security') ON CONFLICT DO NOTHING;
INSERT INTO functional_areas (functional_area_name) VALUES('Dataminer') ON CONFLICT DO NOTHING;
INSERT INTO functional_areas (functional_area_name) VALUES('Development') ON CONFLICT DO NOTHING;

INSERT INTO programs (program_name, functional_area_id) VALUES('Menu', (SELECT id FROM functional_areas WHERE functional_area_name = 'Security')) ON CONFLICT DO NOTHING;
INSERT INTO programs (program_name, functional_area_id) VALUES('Reports', (SELECT id FROM functional_areas WHERE functional_area_name = 'Dataminer')) ON CONFLICT DO NOTHING;
INSERT INTO programs (program_name, functional_area_id) VALUES('Generators', (SELECT id FROM functional_areas WHERE functional_area_name = 'Development')) ON CONFLICT DO NOTHING;
INSERT INTO programs (program_name, functional_area_id) VALUES('Masterfiles', (SELECT id FROM functional_areas WHERE functional_area_name = 'Development')) ON CONFLICT DO NOTHING;

INSERT INTO programs_users (user_id, program_id, security_group_id)
VALUES ((SELECT id FROM users ORDER BY id LIMIT 1),
  (SELECT id FROM programs WHERE program_name = 'Menu' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'Security')),
  (SELECT id FROM security_groups g WHERE g.security_group_name = 'basic')) ON CONFLICT DO NOTHING;

INSERT INTO programs_users (user_id, program_id, security_group_id)
VALUES ((SELECT id FROM users ORDER BY id LIMIT 1),
  (SELECT id FROM programs WHERE program_name = 'Reports' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'Dataminer')),
  (SELECT id FROM security_groups g WHERE g.security_group_name = 'basic')) ON CONFLICT DO NOTHING;

INSERT INTO programs_users (user_id, program_id, security_group_id)
VALUES ((SELECT id FROM users ORDER BY id LIMIT 1),
  (SELECT id FROM programs WHERE program_name = 'Generators' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'Development')),
  (SELECT id FROM security_groups g WHERE g.security_group_name = 'basic')) ON CONFLICT DO NOTHING;

INSERT INTO programs_users (user_id, program_id, security_group_id)
VALUES ((SELECT id FROM users ORDER BY id LIMIT 1),
  (SELECT id FROM programs WHERE program_name = 'Masterfiles' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'Development')),
  (SELECT id FROM security_groups g WHERE g.security_group_name = 'user_maintainer')) ON CONFLICT DO NOTHING;
