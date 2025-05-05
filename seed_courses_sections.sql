-- Seed subjects (courses) with proper codes and full names
INSERT INTO subjects (name, code, description)
VALUES 
    ('Bachelor of Science in Information Technology', 'BSIT', 'A program that focuses on the design of technological information systems, including computing systems, as solutions for business and research data and communications support needs.'),
    ('Bachelor of Science in Computer Science', 'BSCS', 'A program that focuses on computer theory, computing problems and solutions, and the design of computer systems and user interfaces from a scientific perspective.')
ON CONFLICT (code) DO UPDATE SET 
    name = EXCLUDED.name,
    description = EXCLUDED.description;

-- Create labs with specific sections
INSERT INTO labs (name, section, day_of_week, start_time, end_time, subject_id)
SELECT
    'Programming Laboratory', 
    'A2021',
    'Monday',
    '09:00',
    '11:00',
    id
FROM subjects WHERE code = 'BSIT';

INSERT INTO labs (name, section, day_of_week, start_time, end_time, subject_id)
SELECT
    'Programming Laboratory', 
    'B2021',
    'Tuesday',
    '13:00',
    '15:00',
    id
FROM subjects WHERE code = 'BSIT';

INSERT INTO labs (name, section, day_of_week, start_time, end_time, subject_id)
SELECT
    'Programming Laboratory', 
    'C2021',
    'Wednesday',
    '10:00',
    '12:00',
    id
FROM subjects WHERE code = 'BSIT';

INSERT INTO labs (name, section, day_of_week, start_time, end_time, subject_id)
SELECT
    'Database Laboratory', 
    'A2021',
    'Thursday',
    '09:00',
    '11:00',
    id
FROM subjects WHERE code = 'BSCS';

INSERT INTO labs (name, section, day_of_week, start_time, end_time, subject_id)
SELECT
    'Database Laboratory', 
    'B2021',
    'Friday',
    '13:00',
    '15:00',
    id
FROM subjects WHERE code = 'BSCS';

INSERT INTO labs (name, section, day_of_week, start_time, end_time, subject_id)
SELECT
    'Database Laboratory', 
    'C2021',
    'Thursday',
    '15:00',
    '17:00',
    id
FROM subjects WHERE code = 'BSCS'; 