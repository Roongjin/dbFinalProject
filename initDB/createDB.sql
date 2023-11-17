CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE individual(
    individual_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    email varchar(255) NOT NULL
);

CREATE TABLE users(
    individual_id uuid PRIMARY KEY,
    address varchar(255) NOT NULL,
    phone_number char(10) NOT NULL,
    password varchar(255) NOT NULL,
    profile_pic varchar(255),
    full_name varchar(255) NOT NULL,
    username varchar(255) NOT NULL,
    date_of_birth date NOT NULL,
    CONSTRAINT fk_indivID FOREIGN KEY (individual_id) REFERENCES individual(individual_id)
);

CREATE TYPE gender AS enum(
    'M',
    'F'
);

CREATE TYPE animalType AS enum(
    'Canine',
    'Feline'
);

CREATE TABLE pet(
    pet_name varchar(255),
    gender gender NOT NULL,
    individual_id uuid,
    age int NOT NULL,
    animal_type animalType NOT NULL,
    health_info varchar(255),
    certificates varchar(255),
    behavioral_note varchar(255),
    vaccinations varchar(255) ARRAY,
    diety_preferences varchar(255),
    CONSTRAINT fk_indivID FOREIGN KEY (individual_id) REFERENCES individual(individual_id),
    PRIMARY KEY (individual_id, pet_name)
);

CREATE TABLE svcp(
    individual_id uuid PRIMARY KEY,
    svcp_img varchar(255),
    svcp_username varchar(255) NOT NULL,
    svcp_password varchar(255) NOT NULL,
    is_verified boolean NOT NULL,
    svcp_reponsible_person uuid NOT NULL,
    license varchar(255) ARRAY,
    location varchar(255),
    CONSTRAINT fk_indivID FOREIGN KEY (individual_id) REFERENCES individual(individual_id),
    CONSTRAINT fk_respID FOREIGN KEY (svcp_reponsible_person) REFERENCES individual(individual_id)
);

CREATE TABLE admin(
    individual_id uuid PRIMARY KEY,
    admin_name varchar(255) NOT NULL,
    CONSTRAINT fk_indivID FOREIGN KEY (individual_id) REFERENCES individual(individual_id)
);

CREATE TYPE typeOfServices AS enum(
    'Grooming',
    'Dog walking',
    'Pet sitting'
);

CREATE TABLE service(
    service_type typeOfServices NOT NULL,
    individual_id uuid,
    service_img varchar(255) ARRAY NOT NULL,
    average_rating float8,
    require_cert boolean NOT NULL,
    description varchar(255),
    CONSTRAINT fk_svcpID FOREIGN KEY (individual_id) REFERENCES svcp(individual_id),
    PRIMARY KEY (individual_id, service_type)
);

CREATE TABLE timeslot(
    startTime timestamptz NOT NULL,
    endTime timestamptz NOT NULL,
    capacity int NOT NULL,
    price int NOT NULL,
    current_available_slot int NOT NULL,
    service_type typeOfServices NOT NULL,
    individual_id uuid,
    CONSTRAINT fk_svcpID FOREIGN KEY (individual_id) REFERENCES svcp(individual_id),
    PRIMARY KEY (startTime, endTime, service_type, individual_id)
);

CREATE TYPE bookingStatus AS enum(
    'Booked',
    'InProgress',
    'Completed'
);

CREATE TYPE refundStatus AS enum(
    'NoRefund',
    'RefundRequested',
    'Refunded'
);

CREATE TYPE typeOfPayments AS enum(
    'BankTransfer',
    'PromptPay'
);

CREATE TABLE payment_method(
    payment_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    payment_type typeOfPayments NOT NULL,
    bank_name varchar(255),
    account_number varchar(63),
    promptpay_number varchar(63),
    individual_id uuid NOT NULL,
    CONSTRAINT fk_indivID FOREIGN KEY (individual_id) REFERENCES individual(individual_id)
);

CREATE TABLE booking(
    bid uuid PRIMARY KEY,
    status bookingStatus NOT NULL,
    booking_timestamp timestamptz NOT NULL,
    total_booking_value int NOT NULL,
    individual_id uuid NOT NULL,
    refund_status refundStatus NOT NULL,
    refund_timestamp timestamptz,
    refund_value int,
    payin_payment_id uuid NOT NULL,
    payout_payment_id uuid NOT NULL,
    rating int,
    feedback varchar(255),
    CONSTRAINT fk_userID FOREIGN KEY (individual_id) REFERENCES users(individual_id),
    CONSTRAINT fk_payin FOREIGN KEY (payin_payment_id) REFERENCES payment_method(payment_id),
    CONSTRAINT fk_payout FOREIGN KEY (payout_payment_id) REFERENCES payment_method(payment_id)
);

CREATE TABLE message(
    message_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    receiver_id uuid NOT NULL,
    sender_id uuid NOT NULL,
    msg_content varchar(255) NOT NULL,
    msg_timestamp timestamptz NOT NULL,
    CONSTRAINT fk_receiver FOREIGN KEY (receiver_id) REFERENCES individual(individual_id),
    CONSTRAINT fk_sender FOREIGN KEY (sender_id) REFERENCES individual(individual_id)
);

CREATE TABLE reserve(
    startTime timestamptz NOT NULL,
    endTime timestamptz NOT NULL,
    service_type typeOfServices NOT NULL,
    individual_id uuid NOT NULL,
    bid uuid NOT NULL,
    quantity int NOT NULL,
    CONSTRAINT fk_timeslot FOREIGN KEY (individual_id, service_type, startTime, endTime) REFERENCES timeslot(individual_id, service_type, startTime, endTime),
    CONSTRAINT fk_bid FOREIGN KEY (bid) REFERENCES booking(bid),
    PRIMARY KEY (startTime, endTime, service_type, bid)
);

CREATE TABLE issue(
    issue_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    individual_id uuid NOT NULL,
    admin_id uuid NOT NULL,
    issue_context varchar(255) NOT NULL,
    CONSTRAINT fk_poster FOREIGN KEY (individual_id) REFERENCES individual(individual_id),
    CONSTRAINT fk_superviser FOREIGN KEY (admin_id) REFERENCES admin(individual_id)
);

INSERT INTO individual(individual_id, email)
    VALUES ('123e4567-e89b-12d3-a456-426614174001', 'john.doe@example.com'),
('123e4567-e89b-12d3-a456-426614174002', 'jane.smith@example.com'),
('123e4567-e89b-12d3-a456-426614174003', 'bob.jones@example.com'),
('123e4567-e89b-12d3-a456-426614174004', 'alice.wonder@example.com'),
('123e4567-e89b-12d3-a456-426614174005', 'charlie.brown@example.com'),
('123e4567-e89b-12d3-a456-426614174006', 'diana.rogers@example.com'),
('123e4567-e89b-12d3-a456-426614174007', 'edward.white@example.com'),
('123e4567-e89b-12d3-a456-426614174008', 'fiona.miller@example.com'),
('123e4567-e89b-12d3-a456-426614174009', 'george.green@example.com'),
('123e4567-e89b-12d3-a456-426614174010', 'helen.black@example.com'),
('123e4567-e89b-12d3-a456-426614174011', 'ian.jenkins@example.com'),
('123e4567-e89b-12d3-a456-426614174012', 'jessica.cole@example.com'),
('123e4567-e89b-12d3-a456-426614174013', 'kevin.adams@example.com'),
('123e4567-e89b-12d3-a456-426614174014', 'lisa.hill@example.com'),
('123e4567-e89b-12d3-a456-426614174015', 'michael.turner@example.com'),
('123e4567-e89b-12d3-a456-426614174016', 'natalie.baker@example.com'),
('123e4567-e89b-12d3-a456-426614174017', 'oscar.morris@example.com'),
('123e4567-e89b-12d3-a456-426614174018', 'pamela.smith@example.com'),
('123e4567-e89b-12d3-a456-426614174019', 'quincy.parker@example.com'),
('123e4567-e89b-12d3-a456-426614174020', 'rachel.white@example.com'),
('123e4567-e89b-12d3-a456-426614174098', 'victor.jones@example.com'),
('123e4567-e89b-12d3-a456-426614174099', 'wanda.smith@example.com'),
('123e4567-e89b-12d3-a456-426614174100', 'xavier.green@example.com'),
('123e4567-e89b-12d3-a456-426614174040', 'user040@example.com'),
('123e4567-e89b-12d3-a456-426614174041', 'user041@example.com'),
('123e4567-e89b-12d3-a456-426614174042', 'user042@example.com'),
('123e4567-e89b-12d3-a456-426614174043', 'user043@example.com'),
('123e4567-e89b-12d3-a456-426614174044', 'user044@example.com'),
('123e4567-e89b-12d3-a456-426614174045', 'user045@example.com'),
('123e4567-e89b-12d3-a456-426614174046', 'user046@example.com'),
('123e4567-e89b-12d3-a456-426614174047', 'user047@example.com'),
('123e4567-e89b-12d3-a456-426614174048', 'user048@example.com'),
('123e4567-e89b-12d3-a456-426614174049', 'user049@example.com'),
('123e4567-e89b-12d3-a456-426614174059', 'user059@example.com'),
('123e4567-e89b-12d3-a456-426614174060', 'user060@example.com'),
('123e4567-e89b-12d3-a456-426614174070', 'admin070@example.com'),
('123e4567-e89b-12d3-a456-426614174061', 'admin061@example.com'),
('123e4567-e89b-12d3-a456-426614174062', 'admin062@example.com'),
('123e4567-e89b-12d3-a456-426614174063', 'admin063@example.com'),
('123e4567-e89b-12d3-a456-426614174064', 'admin064@example.com'),
('123e4567-e89b-12d3-a456-426614174065', 'admin065@example.com'),
('123e4567-e89b-12d3-a456-426614174066', 'admin066@example.com'),
('123e4567-e89b-12d3-a456-426614174067', 'admin067@example.com'),
('123e4567-e89b-12d3-a456-426614174068', 'admin068@example.com'),
('123e4567-e89b-12d3-a456-426614174069', 'admin069@example.com');

INSERT INTO svcp(individual_id, svcp_img, svcp_username, svcp_password, is_verified, svcp_reponsible_person, license, location)
    VALUES ('123e4567-e89b-12d3-a456-426614174001', 'img_john_doe.jpg', 'john_doe_svc', 'john_password', TRUE, '123e4567-e89b-12d3-a456-426614174001', ARRAY['license1', 'license2'], 'New York'),
('123e4567-e89b-12d3-a456-426614174002', 'img_jane_smith.jpg', 'jane_smith_svc', 'jane_password', FALSE, '123e4567-e89b-12d3-a456-426614174002', NULL, 'Los Angeles'),
('123e4567-e89b-12d3-a456-426614174003', 'img_bob_jones.jpg', 'bob_jones_svc', 'bob_password', TRUE, '123e4567-e89b-12d3-a456-426614174003', ARRAY['license5', 'license6'], 'Chicago'),
('123e4567-e89b-12d3-a456-426614174004', 'img_alice_wonder.jpg', 'alice_wonder_svc', 'alice_password', TRUE, '123e4567-e89b-12d3-a456-426614174004', NULL, 'Miami'),
('123e4567-e89b-12d3-a456-426614174005', 'img_charlie_brown.jpg', 'charlie_brown_svc', 'charlie_password', FALSE, '123e4567-e89b-12d3-a456-426614174005', NULL, 'Seattle'),
('123e4567-e89b-12d3-a456-426614174006', 'img_diana_rogers.jpg', 'diana_rogers_svc', 'diana_password', TRUE, '123e4567-e89b-12d3-a456-426614174006', ARRAY['license11', 'license12'], 'Dallas'),
('123e4567-e89b-12d3-a456-426614174007', 'img_edward_white.jpg', 'edward_white_svc', 'edward_password', TRUE, '123e4567-e89b-12d3-a456-426614174007', ARRAY['license13', 'license14'], 'Houston'),
('123e4567-e89b-12d3-a456-426614174008', 'img_fiona_miller.jpg', 'fiona_miller_svc', 'fiona_password', TRUE, '123e4567-e89b-12d3-a456-426614174008', ARRAY['license15', 'license16'], 'Phoenix'),
('123e4567-e89b-12d3-a456-426614174009', 'img_george_green.jpg', 'george_green_svc', 'george_password', FALSE, '123e4567-e89b-12d3-a456-426614174008', NULL, 'Atlanta'),
('123e4567-e89b-12d3-a456-426614174010', 'img_rachel_white.jpg', 'rachel_white_svc', 'rachel_password', TRUE, '123e4567-e89b-12d3-a456-426614174007', NULL, 'San Francisco'),
('123e4567-e89b-12d3-a456-426614174011', 'img_ian_jenkins.jpg', 'ian_jenkins_svc', 'ian_password', TRUE, '123e4567-e89b-12d3-a456-426614174011', ARRAY['license21', 'license22'], 'Denver'),
('123e4567-e89b-12d3-a456-426614174012', 'img_jessica_cole.jpg', 'jessica_cole_svc', 'jessica_password', TRUE, '123e4567-e89b-12d3-a456-426614174012', ARRAY['license23', 'license24'], 'Philadelphia'),
('123e4567-e89b-12d3-a456-426614174013', 'img_kevin_adams.jpg', 'kevin_adams_svc', 'kevin_password', TRUE, '123e4567-e89b-12d3-a456-426614174013', ARRAY['license25', 'license26'], 'Austin'),
('123e4567-e89b-12d3-a456-426614174014', 'img_lisa_hill.jpg', 'lisa_hill_svc', 'lisa_password', TRUE, '123e4567-e89b-12d3-a456-426614174014', NULL, 'Portland'),
('123e4567-e89b-12d3-a456-426614174015', 'img_michael_turner.jpg', 'michael_turner_svc', 'michael_password', TRUE, '123e4567-e89b-12d3-a456-426614174015', ARRAY['license29', 'license30'], 'Orlando'),
('123e4567-e89b-12d3-a456-426614174016', 'img_natalie_baker.jpg', 'natalie_baker_svc', 'natalie_password', TRUE, '123e4567-e89b-12d3-a456-426614174016', ARRAY['license31', 'license32'], 'Raleigh'),
('123e4567-e89b-12d3-a456-426614174017', 'img_oscar_morris.jpg', 'oscar_morris_svc', 'oscar_password', TRUE, '123e4567-e89b-12d3-a456-426614174017', NULL, 'Nashville'),
('123e4567-e89b-12d3-a456-426614174018', 'img_pamela_smith.jpg', 'pamela_smith_svc', 'pamela_password', TRUE, '123e4567-e89b-12d3-a456-426614174018', ARRAY['license35', 'license36'], 'Minneapolis'),
('123e4567-e89b-12d3-a456-426614174019', 'img_quincy_parker.jpg', 'quincy_parker_svc', 'quincy_password', FALSE, '123e4567-e89b-12d3-a456-426614174019', NULL, 'Kansas City');

INSERT INTO users(individual_id, address, phone_number, PASSWORD, profile_pic, full_name, username, date_of_birth)
    VALUES ('123e4567-e89b-12d3-a456-426614174040', '777 Maple St, Apt 3, San Francisco, CA', '7778889999', 'user040_password', 'user040_profile_pic.jpg', 'User 040', 'user040', '1987-06-30'),
('123e4567-e89b-12d3-a456-426614174041', '888 Elm Ave, Denver, CO', '8889990000', 'user041_password', 'user041_profile_pic.jpg', 'User 041', 'user041', '1993-03-14'),
('123e4567-e89b-12d3-a456-426614174042', '999 Pine St, Philadelphia, PA', '9990001111', 'user042_password', 'user042_profile_pic.jpg', 'User 042', 'user042', '1986-09-05'),
('123e4567-e89b-12d3-a456-426614174043', '101 Oakwood Dr, Austin, TX', '1012023030', 'user043_password', 'user043_profile_pic.jpg', 'User 043', 'user043', '1996-11-22'),
('123e4567-e89b-12d3-a456-426614174044', '202 Cedar Ln, Portland, OR', '2023034040', 'user044_password', 'user044_profile_pic.jpg', 'User 044', 'user044', '1989-08-10'),
('123e4567-e89b-12d3-a456-426614174045', '303 Walnut Dr, Orlando, FL', '3034045050', 'user045_password', 'user045_profile_pic.jpg', 'User 045', 'user045', '1990-04-02'),
('123e4567-e89b-12d3-a456-426614174046', '404 Pine Ave, Raleigh, NC', '4045056060', 'user046_password', 'user046_profile_pic.jpg', 'User 046', 'user046', '1985-12-15'),
('123e4567-e89b-12d3-a456-426614174047', '505 Cedar St, Nashville, TN', '5056067070', 'user047_password', 'user047_profile_pic.jpg', 'User 047', 'user047', '1997-07-28'),
('123e4567-e89b-12d3-a456-426614174048', '606 Oak Ln, Minneapolis, MN', '6067078080', 'user048_password', 'user048_profile_pic.jpg', 'User 048', 'user048', '1982-02-18'),
('123e4567-e89b-12d3-a456-426614174049', '707 Walnut Ave, Kansas City, MO', '7078089090', 'user049_password', 'user049_profile_pic.jpg', 'User 049', 'user049', '1994-05-07'),
('123e4567-e89b-12d3-a456-426614174059', '909 Pine St, New Orleans, LA', '9091011121', 'user059_password', 'user059_profile_pic.jpg', 'User 059', 'user059', '1984-07-23'),
('123e4567-e89b-12d3-a456-426614174060', '1010 Cedar Dr, Chicago, IL', '1011121213', 'user060_password', 'user060_profile_pic.jpg', 'User 060', 'user060', '1991-01-11');

INSERT INTO admin(individual_id, admin_name)
    VALUES ('123e4567-e89b-12d3-a456-426614174070', 'Admin 070'),
('123e4567-e89b-12d3-a456-426614174061', 'Admin 061'),
('123e4567-e89b-12d3-a456-426614174062', 'Admin 062'),
('123e4567-e89b-12d3-a456-426614174063', 'Admin 063'),
('123e4567-e89b-12d3-a456-426614174064', 'Admin 064'),
('123e4567-e89b-12d3-a456-426614174065', 'Admin 065'),
('123e4567-e89b-12d3-a456-426614174066', 'Admin 066'),
('123e4567-e89b-12d3-a456-426614174067', 'Admin 067'),
('123e4567-e89b-12d3-a456-426614174068', 'Admin 068'),
('123e4567-e89b-12d3-a456-426614174069', 'Admin 069');

INSERT INTO pet(pet_name, gender, individual_id, age, animal_type, health_info, certificates, behavioral_note, vaccinations, diety_preferences)
    VALUES ('Buddy', 'M', '123e4567-e89b-12d3-a456-426614174040', 3, 'Canine', 'Healthy and active', 'Vaccination Certificate', 'Friendly and playful', ARRAY['Rabies', 'Distemper'], 'Regular diet'),
('Whiskers', 'F', '123e4567-e89b-12d3-a456-426614174040', 2, 'Feline', 'Regular check-ups', 'Health Certificate', 'Shy but affectionate', ARRAY['Feline Leukemia'], 'Special diet for sensitive stomach'),
('Max', 'M', '123e4567-e89b-12d3-a456-426614174041', 4, 'Canine', 'Energetic and friendly', 'Training Certificate', 'Loves outdoor activities', ARRAY['Rabies', 'Bordetella'], 'Balanced diet'),
('Luna', 'F', '123e4567-e89b-12d3-a456-426614174041', 1, 'Feline', 'Indoor lifestyle', 'Vet Health Check', 'Calm and independent', ARRAY['Feline Leukemia'], 'Regular cat food'),
('Rocky', 'M', '123e4567-e89b-12d3-a456-426614174059', 5, 'Canine', 'Strong and healthy', 'Training and Health Certificates', 'Loyal and protective', ARRAY['Rabies', 'Distemper'], 'High-protein diet'),
('Mittens', 'F', '123e4567-e89b-12d3-a456-426614174059', 3, 'Feline', 'Adopted from shelter', 'Health Certificate', 'Playful and curious', ARRAY['Feline Leukemia'], 'Regular cat food'),
('Rusty', 'M', '123e4567-e89b-12d3-a456-426614174060', 2, 'Canine', 'Sociable and well-behaved', 'Vaccination Certificate', 'Eager to please', ARRAY['Rabies', 'Bordetella'], 'Balanced diet'),
('Whiskey', 'F', '123e4567-e89b-12d3-a456-426614174060', 1, 'Feline', 'Healthy and playful', 'Health Certificate', 'Likes to nap', ARRAY['Feline Leukemia'], 'Regular cat food');

INSERT INTO service(service_type, individual_id, service_img, average_rating, require_cert, description)
    VALUES ('Grooming', '123e4567-e89b-12d3-a456-426614174001', ARRAY['grooming_img1.jpg', 'grooming_img2.jpg'], 4.5, TRUE, 'Professional grooming service for dogs and cats'),
('Dog walking', '123e4567-e89b-12d3-a456-426614174001', ARRAY['dog_walking_img1.jpg', 'dog_walking_img2.jpg'], 4.8, FALSE, 'Reliable dog walking service with flexible schedules'),
('Pet sitting', '123e4567-e89b-12d3-a456-426614174001', ARRAY['pet_sitting_img1.jpg', 'pet_sitting_img2.jpg'], 4.2, TRUE, 'Experienced pet sitting service in a comfortable environment'),
('Grooming', '123e4567-e89b-12d3-a456-426614174002', ARRAY['grooming_img3.jpg', 'grooming_img4.jpg'], 4.6, TRUE, 'Professional grooming service with attention to pet comfort'),
('Dog walking', '123e4567-e89b-12d3-a456-426614174002', ARRAY['dog_walking_img3.jpg', 'dog_walking_img4.jpg'], 4.7, FALSE, 'Dedicated dog walking service with personalized care'),
('Pet sitting', '123e4567-e89b-12d3-a456-426614174002', ARRAY['pet_sitting_img3.jpg', 'pet_sitting_img4.jpg'], 4.4, TRUE, 'Safe and cozy pet sitting service for all types of pets'),
('Grooming', '123e4567-e89b-12d3-a456-426614174003', ARRAY['grooming_img5.jpg', 'grooming_img6.jpg'], 4.6, TRUE, 'Professional grooming service with attention to pet comfort'),
('Dog walking', '123e4567-e89b-12d3-a456-426614174003', ARRAY['dog_walking_img5.jpg', 'dog_walking_img6.jpg'], 4.7, FALSE, 'Dedicated dog walking service with personalized care'),
('Grooming', '123e4567-e89b-12d3-a456-426614174010', ARRAY['grooming_img19.jpg', 'grooming_img20.jpg'], 4.0, FALSE, 'Quality grooming service with a variety of styling options'),
('Dog walking', '123e4567-e89b-12d3-a456-426614174010', ARRAY['dog_walking_img19.jpg', 'dog_walking_img20.jpg'], 4.5, TRUE, 'Trusted dog walking service with experienced walkers'),
('Pet sitting', '123e4567-e89b-12d3-a456-426614174010', ARRAY['pet_sitting_img19.jpg', 'pet_sitting_img20.jpg'], 3.8, FALSE, 'Comfortable and secure pet sitting service with regular updates');

INSERT INTO timeslot(startTime, endTime, capacity, price, current_available_slot, service_type, individual_id)
    VALUES ('2023-11-16 09:00:00', '2023-11-16 10:00:00', 5, 20, 5, 'Grooming', '123e4567-e89b-12d3-a456-426614174001'),
('2023-11-16 10:30:00', '2023-11-16 11:30:00', 8, 25, 8, 'Grooming', '123e4567-e89b-12d3-a456-426614174001'),
('2023-11-16 12:00:00', '2023-11-16 13:00:00', 6, 30, 6, 'Grooming', '123e4567-e89b-12d3-a456-426614174001'),
('2023-11-17 13:30:00', '2023-11-17 14:30:00', 4, 18, 4, 'Grooming', '123e4567-e89b-12d3-a456-426614174002'),
('2023-11-17 15:00:00', '2023-11-17 16:00:00', 7, 22, 7, 'Dog walking', '123e4567-e89b-12d3-a456-426614174002'),
('2023-11-17 16:30:00', '2023-11-17 17:30:00', 5, 28, 5, 'Pet sitting', '123e4567-e89b-12d3-a456-426614174002'),
('2023-11-18 10:30:00', '2023-11-18 11:30:00', 9, 32, 9, 'Dog walking', '123e4567-e89b-12d3-a456-426614174003'),
('2023-11-18 12:00:00', '2023-11-18 13:00:00', 3, 15, 3, 'Pet sitting', '123e4567-e89b-12d3-a456-426614174003'),
('2023-11-19 13:30:00', '2023-11-19 14:30:00', 8, 28, 8, 'Dog walking', '123e4567-e89b-12d3-a456-426614174004'),
('2023-11-19 15:00:00', '2023-11-19 16:00:00', 5, 20, 5, 'Dog walking', '123e4567-e89b-12d3-a456-426614174004'),
('2023-11-19 16:30:00', '2023-11-19 17:30:00', 7, 26, 7, 'Dog walking', '123e4567-e89b-12d3-a456-426614174004'),
('2023-11-20 09:30:00', '2023-11-20 10:30:00', 4, 18, 4, 'Grooming', '123e4567-e89b-12d3-a456-426614174005'),
('2023-11-20 11:00:00', '2023-11-20 12:00:00', 7, 22, 7, 'Dog walking', '123e4567-e89b-12d3-a456-426614174005'),
('2023-11-20 12:30:00', '2023-11-20 13:30:00', 5, 25, 5, 'Pet sitting', '123e4567-e89b-12d3-a456-426614174005');

INSERT INTO payment_method(payment_id, payment_type, bank_name, account_number, promptpay_number, individual_id)
    VALUES ('123e4567-e89b-12d3-a456-426614174101', 'BankTransfer', 'JKL Bank', '4567890123', NULL, '123e4567-e89b-12d3-a456-426614174011'),
('123e4567-e89b-12d3-a456-426614174102', 'PromptPay', NULL, NULL, '0890123456', '123e4567-e89b-12d3-a456-426614174012'),
('123e4567-e89b-12d3-a456-426614174103', 'BankTransfer', 'MNO Bank', '5678901234', NULL, '123e4567-e89b-12d3-a456-426614174013'),
('123e4567-e89b-12d3-a456-426614174104', 'PromptPay', NULL, NULL, '0987654321', '123e4567-e89b-12d3-a456-426614174014'),
('123e4567-e89b-12d3-a456-426614174105', 'BankTransfer', 'PQR Bank', '1234567890', NULL, '123e4567-e89b-12d3-a456-426614174015'),
('123e4567-e89b-12d3-a456-426614174106', 'PromptPay', NULL, NULL, '0123456789', '123e4567-e89b-12d3-a456-426614174016'),
('123e4567-e89b-12d3-a456-426614174107', 'BankTransfer', 'STU Bank', '2345678901', NULL, '123e4567-e89b-12d3-a456-426614174017'),
('123e4567-e89b-12d3-a456-426614174108', 'PromptPay', NULL, NULL, '0765432109', '123e4567-e89b-12d3-a456-426614174018'),
('123e4567-e89b-12d3-a456-426614174109', 'BankTransfer', 'VWX Bank', '3456789012', NULL, '123e4567-e89b-12d3-a456-426614174019'),
('123e4567-e89b-12d3-a456-426614174110', 'PromptPay', NULL, NULL, '0876543210', '123e4567-e89b-12d3-a456-426614174020'),
('123e4567-e89b-12d3-a456-426614174111', 'BankTransfer', 'ABC Bank', '9876543210', NULL, '123e4567-e89b-12d3-a456-426614174041'),
('123e4567-e89b-12d3-a456-426614174112', 'PromptPay', NULL, NULL, '0812345678', '123e4567-e89b-12d3-a456-426614174041'),
('123e4567-e89b-12d3-a456-426614174113', 'BankTransfer', 'XYZ Bank', '8765432109', NULL, '123e4567-e89b-12d3-a456-426614174042'),
('123e4567-e89b-12d3-a456-426614174114', 'PromptPay', NULL, NULL, '0923456789', '123e4567-e89b-12d3-a456-426614174042'),
('123e4567-e89b-12d3-a456-426614174115', 'BankTransfer', 'PQR Bank', '7654321098', NULL, '123e4567-e89b-12d3-a456-426614174043'),
('123e4567-e89b-12d3-a456-426614174116', 'PromptPay', NULL, NULL, '0654321098', '123e4567-e89b-12d3-a456-426614174044'),
('123e4567-e89b-12d3-a456-426614174117', 'BankTransfer', 'VWX Bank', '6543210987', NULL, '123e4567-e89b-12d3-a456-426614174059'),
('123e4567-e89b-12d3-a456-426614174118', 'PromptPay', NULL, NULL, '0876543210', '123e4567-e89b-12d3-a456-426614174060');

INSERT INTO booking(bid, status, booking_timestamp, total_booking_value, individual_id, refund_status, refund_timestamp, refund_value, payin_payment_id, payout_payment_id, rating, feedback)
    VALUES ('123e4567-e89b-12d3-a456-426614174103', 'Completed', '2023-11-18 09:45:00', 60, '123e4567-e89b-12d3-a456-426614174043', 'NoRefund', NULL, NULL, '123e4567-e89b-12d3-a456-426614174115', '123e4567-e89b-12d3-a456-426614174101', 4, 'Great service!'),
('123e4567-e89b-12d3-a456-426614174120', 'Booked', '2023-11-20 10:00:00', 45, '123e4567-e89b-12d3-a456-426614174043', 'NoRefund', NULL, NULL, '123e4567-e89b-12d3-a456-426614174115', '123e4567-e89b-12d3-a456-426614174101', NULL, NULL),
('123e4567-e89b-12d3-a456-426614174121', 'Booked', '2023-11-21 14:30:00', 55, '123e4567-e89b-12d3-a456-426614174044', 'NoRefund', NULL, NULL, '123e4567-e89b-12d3-a456-426614174116', '123e4567-e89b-12d3-a456-426614174102', NULL, NULL),
('123e4567-e89b-12d3-a456-426614174122', 'InProgress', '2023-11-22 16:00:00', 70, '123e4567-e89b-12d3-a456-426614174042', 'RefundRequested', NULL, 70, '123e4567-e89b-12d3-a456-426614174113', '123e4567-e89b-12d3-a456-426614174103', NULL, NULL),
('123e4567-e89b-12d3-a456-426614174123', 'Completed', '2023-11-23 10:15:00', 65, '123e4567-e89b-12d3-a456-426614174043', 'NoRefund', NULL, NULL, '123e4567-e89b-12d3-a456-426614174115', '123e4567-e89b-12d3-a456-426614174103', 5, 'Excellent service!'),
('123e4567-e89b-12d3-a456-426614174140', 'Booked', '2023-11-25 11:30:00', 48, '123e4567-e89b-12d3-a456-426614174044', 'NoRefund', NULL, NULL, '123e4567-e89b-12d3-a456-426614174116', '123e4567-e89b-12d3-a456-426614174104', NULL, NULL),
('123e4567-e89b-12d3-a456-426614174141', 'Booked', '2023-11-26 13:45:00', 42, '123e4567-e89b-12d3-a456-426614174044', 'NoRefund', NULL, NULL, '123e4567-e89b-12d3-a456-426614174116', '123e4567-e89b-12d3-a456-426614174105', NULL, NULL),
('123e4567-e89b-12d3-a456-426614174142', 'InProgress', '2023-11-27 15:15:00', 68, '123e4567-e89b-12d3-a456-426614174059', 'RefundRequested', NULL, 65, '123e4567-e89b-12d3-a456-426614174117', '123e4567-e89b-12d3-a456-426614174106', NULL, NULL),
('123e4567-e89b-12d3-a456-426614174143', 'Completed', '2023-11-28 09:30:00', 55, '123e4567-e89b-12d3-a456-426614174060', 'NoRefund', NULL, NULL, '123e4567-e89b-12d3-a456-426614174118', '123e4567-e89b-12d3-a456-426614174107', 4, 'Very satisfied with the service!'),
('123e4567-e89b-12d3-a456-426614174150', 'Completed', '2023-11-30 10:45:00', 50, '123e4567-e89b-12d3-a456-426614174060', 'Refunded', '2023-11-30 11:45:00', 45, '123e4567-e89b-12d3-a456-426614174118', '123e4567-e89b-12d3-a456-426614174108', NULL, NULL);

INSERT INTO message(message_id, receiver_id, sender_id, msg_content, msg_timestamp)
    VALUES ('123e4567-e89b-12d3-a456-426614174001', '123e4567-e89b-12d3-a456-426614174041', '123e4567-e89b-12d3-a456-426614174042', 'Message content 1', '2023-11-16 14:00:00'),
('123e4567-e89b-12d3-a456-426614174002', '123e4567-e89b-12d3-a456-426614174042', '123e4567-e89b-12d3-a456-426614174041', 'Message content 2', '2023-11-17 15:30:00'),
('123e4567-e89b-12d3-a456-426614174003', '123e4567-e89b-12d3-a456-426614174042', '123e4567-e89b-12d3-a456-426614174041', 'Message content 3', '2023-11-17 15:35:00'),
('123e4567-e89b-12d3-a456-426614174004', '123e4567-e89b-12d3-a456-426614174041', '123e4567-e89b-12d3-a456-426614174042', 'Message content 4', '2023-11-17 15:40:00'),
('123e4567-e89b-12d3-a456-426614174005', '123e4567-e89b-12d3-a456-426614174045', '123e4567-e89b-12d3-a456-426614174061', 'Message content 5', '2023-11-17 15:30:00'),
('123e4567-e89b-12d3-a456-426614174006', '123e4567-e89b-12d3-a456-426614174043', '123e4567-e89b-12d3-a456-426614174065', 'Message content 6', '2023-11-17 15:35:00'),
('123e4567-e89b-12d3-a456-426614174007', '123e4567-e89b-12d3-a456-426614174047', '123e4567-e89b-12d3-a456-426614174046', 'Message content 7', '2023-11-17 15:40:00');

INSERT INTO issue(issue_id, individual_id, admin_id, issue_context)
    VALUES ('123e4567-e89b-12d3-a456-426614175001', '123e4567-e89b-12d3-a456-426614174041', '123e4567-e89b-12d3-a456-426614174061', 'Issue context 1'),
('123e4567-e89b-12d3-a456-426614175002', '123e4567-e89b-12d3-a456-426614174042', '123e4567-e89b-12d3-a456-426614174062', 'Issue context 2'),
('123e4567-e89b-12d3-a456-426614175003', '123e4567-e89b-12d3-a456-426614174043', '123e4567-e89b-12d3-a456-426614174063', 'Issue context 3'),
('123e4567-e89b-12d3-a456-426614175004', '123e4567-e89b-12d3-a456-426614174044', '123e4567-e89b-12d3-a456-426614174064', 'Issue context 4'),
('123e4567-e89b-12d3-a456-426614175005', '123e4567-e89b-12d3-a456-426614174059', '123e4567-e89b-12d3-a456-426614174065', 'Issue context 5'),
('123e4567-e89b-12d3-a456-426614175006', '123e4567-e89b-12d3-a456-426614174060', '123e4567-e89b-12d3-a456-426614174066', 'Issue context 6'),
('123e4567-e89b-12d3-a456-426614175007', '123e4567-e89b-12d3-a456-426614174070', '123e4567-e89b-12d3-a456-426614174067', 'Issue context 7'),
('123e4567-e89b-12d3-a456-426614175008', '123e4567-e89b-12d3-a456-426614174061', '123e4567-e89b-12d3-a456-426614174068', 'Issue context 8'),
('123e4567-e89b-12d3-a456-426614175009', '123e4567-e89b-12d3-a456-426614174062', '123e4567-e89b-12d3-a456-426614174069', 'Issue context 9'),
('123e4567-e89b-12d3-a456-426614175010', '123e4567-e89b-12d3-a456-426614174063', '123e4567-e89b-12d3-a456-426614174070', 'Issue context 10');

INSERT INTO reserve(startTime, endTime, service_type, individual_id, bid, quantity)
    VALUES ('2023-11-17 13:30:00', '2023-11-17 14:30:00', 'Grooming', '123e4567-e89b-12d3-a456-426614174002', '123e4567-e89b-12d3-a456-426614174103', 2),
('2023-11-17 15:00:00', '2023-11-17 16:00:00', 'Dog walking', '123e4567-e89b-12d3-a456-426614174002', '123e4567-e89b-12d3-a456-426614174120', 1),
('2023-11-17 16:30:00', '2023-11-17 17:30:00', 'Pet sitting', '123e4567-e89b-12d3-a456-426614174002', '123e4567-e89b-12d3-a456-426614174121', 3),
('2023-11-16 10:30:00', '2023-11-16 11:30:00', 'Grooming', '123e4567-e89b-12d3-a456-426614174001', '123e4567-e89b-12d3-a456-426614174122', 1),
('2023-11-16 12:00:00', '2023-11-16 13:00:00', 'Grooming', '123e4567-e89b-12d3-a456-426614174001', '123e4567-e89b-12d3-a456-426614174123', 2),
('2023-11-18 10:30:00', '2023-11-18 11:30:00', 'Dog walking', '123e4567-e89b-12d3-a456-426614174003', '123e4567-e89b-12d3-a456-426614174140', 1),
('2023-11-18 10:30:00', '2023-11-18 11:30:00', 'Dog walking', '123e4567-e89b-12d3-a456-426614174003', '123e4567-e89b-12d3-a456-426614174141', 2),
('2023-11-20 09:30:00', '2023-11-20 10:30:00', 'Grooming', '123e4567-e89b-12d3-a456-426614174005', '123e4567-e89b-12d3-a456-426614174142', 1),
('2023-11-20 11:00:00', '2023-11-20 12:00:00', 'Dog walking', '123e4567-e89b-12d3-a456-426614174005', '123e4567-e89b-12d3-a456-426614174143', 3),
('2023-11-20 12:30:00', '2023-11-20 13:30:00', 'Pet sitting', '123e4567-e89b-12d3-a456-426614174005', '123e4567-e89b-12d3-a456-426614174150', 2);

INSERT INTO booking(bid, status, booking_timestamp, total_booking_value, individual_id, refund_status, refund_timestamp, refund_value, payin_payment_id, payout_payment_id, rating, feedback)
    VALUES ('123e4567-e89b-12d3-a456-426614174151', 'Completed', '2023-11-22 16:00:00', 65, '123e4567-e89b-12d3-a456-426614174042', 'Refunded', '2023-11-22 16:30:00', 65, '123e4567-e89b-12d3-a456-426614174114', '123e4567-e89b-12d3-a456-426614174103', NULL, NULL),
('123e4567-e89b-12d3-a456-426614174152', 'Completed', '2023-11-22 17:00:00', 80, '123e4567-e89b-12d3-a456-426614174042', 'Refunded', '2023-11-22 17:30:00', 80, '123e4567-e89b-12d3-a456-426614174114', '123e4567-e89b-12d3-a456-426614174103', NULL, NULL),
('123e4567-e89b-12d3-a456-426614174153', 'Completed', '2023-11-22 17:00:00', 80, '123e4567-e89b-12d3-a456-426614174059', 'NoRefund', NULL, NULL, '123e4567-e89b-12d3-a456-426614174117', '123e4567-e89b-12d3-a456-426614174103', 1, NULL),
('123e4567-e89b-12d3-a456-426614174154', 'Completed', '2023-11-23 17:00:00', 80, '123e4567-e89b-12d3-a456-426614174059', 'NoRefund', NULL, NULL, '123e4567-e89b-12d3-a456-426614174117', '123e4567-e89b-12d3-a456-426614174103', 1, NULL),
('123e4567-e89b-12d3-a456-426614174155', 'Completed', '2023-11-24 17:00:00', 80, '123e4567-e89b-12d3-a456-426614174059', 'NoRefund', NULL, NULL, '123e4567-e89b-12d3-a456-426614174117', '123e4567-e89b-12d3-a456-426614174103', 1, NULL);

